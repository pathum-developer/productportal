package com.elvencode.productportal.auth.aop;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

/**
 * Learning-only login execution tracer.
 *
 * <p>This aspect is disabled by default because broad method tracing is noisy and can expose internal
 * implementation details. Enable it only in a local learning/debugging run with
 * {@code auth.login-trace.enabled=true}.</p>
 *
 * <p>Request/response payloads are intentionally not logged because login requests contain
 * credentials and authentication responses contain tokens.</p>
 */
@Aspect
@Component
@Slf4j
@Order(Ordered.HIGHEST_PRECEDENCE)
@ConditionalOnProperty(prefix = "auth.login-trace", name = "enabled", havingValue = "true")
public class AuthControllerExecutionLoggingAspect {

    private static final ThreadLocal<LoginTraceState> LOGIN_TRACE_STATE = new ThreadLocal<>();

    @Pointcut("execution(* com.elvencode.productportal.auth.controller.AuthController.login(..))")
    private void authControllerLoginMethod() {
    }

    @Pointcut("execution(* com.elvencode.productportal..*(..))")
    private void applicationMethod() {
    }

    @Pointcut("within(com.elvencode.productportal..aop..*) "
            + "|| within(com.elvencode.productportal..config..*) "
            + "|| @within(org.springframework.context.annotation.Configuration) "
            + "|| @within(org.springframework.boot.context.properties.ConfigurationProperties)")
    private void tracingExcludedType() {
    }

    @Around("authControllerLoginMethod()")
    public Object traceLoginExecution(ProceedingJoinPoint joinPoint) throws Throwable {
        boolean rootTrace = LOGIN_TRACE_STATE.get() == null;
        if (rootTrace) {
            LOGIN_TRACE_STATE.set(new LoginTraceState());
        }

        try {
            return traceMethodExecution(joinPoint);
        } finally {
            if (rootTrace) {
                LOGIN_TRACE_STATE.remove();
            }
        }
    }

    @Around("applicationMethod() && !authControllerLoginMethod() && !tracingExcludedType()")
    public Object traceNestedMethodExecution(ProceedingJoinPoint joinPoint) throws Throwable {
        if (LOGIN_TRACE_STATE.get() == null) {
            return joinPoint.proceed();
        }

        return traceMethodExecution(joinPoint);
    }

    private Object traceMethodExecution(ProceedingJoinPoint joinPoint) throws Throwable {
        LoginTraceState traceState = LOGIN_TRACE_STATE.get();
        if (traceState == null) {
            return joinPoint.proceed();
        }

        int depth = traceState.depth();
        String indentation = indentation(depth);
        String methodName = joinPoint.getSignature().toShortString();
        long startTime = System.nanoTime();

        log.info("{}Before executing method: {}", indentation, methodName);
        traceState.incrementDepth();

        try {
            Object result = joinPoint.proceed();
            log.info("{}After executing method: {} completed in {} ms",
                    indentation, methodName, elapsedMillis(startTime));
            return result;
        } catch (Throwable exception) {
            log.warn("{}After executing method: {} failed in {} ms with {}",
                    indentation, methodName, elapsedMillis(startTime), exception.toString());
            throw exception;
        } finally {
            traceState.decrementDepth();
        }
    }

    private String indentation(int depth) {
        return "  ".repeat(Math.max(0, depth));
    }

    private long elapsedMillis(long startTime) {
        return TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime);
    }

    private static final class LoginTraceState {

        private int depth;

        private int depth() {
            return depth;
        }

        private void incrementDepth() {
            depth++;
        }

        private void decrementDepth() {
            depth--;
        }
    }
}
