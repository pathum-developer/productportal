package com.elvencode.productportal.auth.protection.repository;

import com.elvencode.productportal.auth.protection.entity.LoginThrottleScope;
import com.elvencode.productportal.auth.protection.entity.LoginThrottleState;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface LoginThrottleStateRepository extends JpaRepository<LoginThrottleState, Long> {

    Optional<LoginThrottleState> findByScopeAndIdentifier(
            LoginThrottleScope scope,
            String identifier);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT state
            FROM LoginThrottleState state
            WHERE state.scope = :scope
              AND state.identifier = :identifier
            """)
    Optional<LoginThrottleState> findByScopeAndIdentifierForUpdate(
            @Param("scope") LoginThrottleScope scope,
            @Param("identifier") String identifier);
}
