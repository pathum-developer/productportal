package com.elvencode.productportal.auth.protection.repository;

import com.elvencode.productportal.auth.protection.entity.LoginAttemptAudit;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LoginAttemptAuditRepository extends JpaRepository<LoginAttemptAudit, Long> {
}
