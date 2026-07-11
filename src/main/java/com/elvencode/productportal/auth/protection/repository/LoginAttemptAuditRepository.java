package com.elvencode.productportal.auth.protection.repository;

import com.elvencode.productportal.auth.protection.entity.LoginAttemptAudit;
import org.springframework.data.repository.Repository;

/**
 * Append-only persistence boundary for login audit events.
 *
 * <p>Do not extend {@code JpaRepository} here. Login audit rows are security evidence, so the
 * application should not expose generic delete/read/write repository methods for this table.</p>
 */
public interface LoginAttemptAuditRepository extends Repository<LoginAttemptAudit, Long> {

    LoginAttemptAudit save(LoginAttemptAudit audit);
}
