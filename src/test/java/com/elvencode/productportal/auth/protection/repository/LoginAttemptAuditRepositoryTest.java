package com.elvencode.productportal.auth.protection.repository;

import com.elvencode.productportal.auth.protection.entity.LoginAttemptAudit;
import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

import java.lang.reflect.Method;
import java.util.Arrays;

import static org.assertj.core.api.Assertions.assertThat;

class LoginAttemptAuditRepositoryTest {

    @Test
    void shouldExposeOnlyAppendOperation() throws NoSuchMethodException {
        assertThat(JpaRepository.class.isAssignableFrom(LoginAttemptAuditRepository.class)).isFalse();

        assertThat(Arrays.stream(LoginAttemptAuditRepository.class.getMethods())
                .map(Method::getName)
                .filter(methodName -> methodName.startsWith("delete")
                        || methodName.startsWith("find")
                        || methodName.startsWith("get")
                        || methodName.startsWith("read")
                        || methodName.startsWith("remove"))
                .toList())
                .isEmpty();

        assertThat(LoginAttemptAuditRepository.class
                .getMethod("save", LoginAttemptAudit.class)
                .getReturnType())
                .isEqualTo(LoginAttemptAudit.class);
    }
}
