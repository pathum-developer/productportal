package com.elvencode.productportal.common.aop.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

/**
 * Cross-cutting performance logging for application entry points.
 *
 * <p>This aspect intentionally monitors only REST controllers and services. It avoids lower-level
 * framework/configuration beans to keep logs useful and prevent noisy startup/internal logging.</p>
 *
 * <p>Method arguments are not logged here because request objects can contain credentials, tokens,
 * personal data, or other sensitive values.</p>
 */
@Aspect
@Component
@Slf4j
public class LoggingAndPerformanceAspect {

    private static final long SLOW_CALL_THRESHOLD_MS = 1_000L;

    @Pointcut("within(com.elvencode.productportal..*)")
    private void applicationPackage() {
    }

    /*
     * Restrict the aspect to the application's web and business boundaries. Repositories, mappers,
     * security configuration, and other infrastructure beans should not be wrapped by this generic
     * logging concern.
     */
    @Pointcut("@within(org.springframework.stereotype.Service) "
            + "|| @within(org.springframework.web.bind.annotation.RestController)")
    private void monitoredSpringBean() {
    }

    /*
     * Around advice can run code before and after the intercepted method. Calling proceed() is what
     * executes the original controller/service method.
     */
    @Around("applicationPackage() && monitoredSpringBean()")
    public Object logAndMeasureExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().toShortString();
        long startTime = System.nanoTime();

        try {
            Object result = joinPoint.proceed();
            logSuccessfulExecution(methodName, elapsedMillis(startTime));
            return result;
        } catch (Throwable exception) {
            log.warn("Failed {} after {} ms: {}", methodName, elapsedMillis(startTime),
                    exception.toString());
            throw exception;
        }
    }

    private void logSuccessfulExecution(String methodName, long elapsedMillis) {
        if (elapsedMillis >= SLOW_CALL_THRESHOLD_MS) {
            log.warn("Slow call {} completed in {} ms", methodName, elapsedMillis);
            return;
        }

        // Log execution time for successful calls at INFO level to ensure visibility
        // in production logs; keep the message structured for log aggregation systems.
        log.info("Completed {} in {} ms", methodName, elapsedMillis);
    }

    private long elapsedMillis(long startTime) {
        // nanoTime is monotonic and is the correct clock for measuring elapsed duration.
        return TimeUnit.NANOSECONDS.toMillis(System.nanoTime() - startTime);
    }

}
