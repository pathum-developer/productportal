package com.elvencode.productportal.auth.session.repository;

import com.elvencode.productportal.auth.session.entity.AuthSession;
import com.elvencode.productportal.auth.session.entity.AuthSessionRevocationReason;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AuthSessionRepository extends JpaRepository<AuthSession, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
            SELECT session
            FROM AuthSession session
            JOIN FETCH session.user
            WHERE session.id = :sessionId
            """)
    Optional<AuthSession> findByIdForUpdate(@Param("sessionId") UUID sessionId);

    @Query("""
            SELECT session
            FROM AuthSession session
            JOIN FETCH session.user
            WHERE session.id = :sessionId
            """)
    Optional<AuthSession> findByIdWithUser(@Param("sessionId") UUID sessionId);

    @Query("""
            SELECT session
            FROM AuthSession session
            WHERE session.user.id = :userId
              AND session.revokedAt IS NULL
              AND session.refreshExpiresAt > :now
            ORDER BY session.lastUsedAt DESC, session.issuedAt DESC
            """)
    List<AuthSession> findActiveSessionsByUserId(
            @Param("userId") Long userId,
            @Param("now") Instant now);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("""
            UPDATE AuthSession session
            SET session.revokedAt = :revokedAt,
                session.revocationReason = :reason
            WHERE session.user.id = :userId
              AND session.revokedAt IS NULL
            """)
    int revokeActiveByUserId(
            @Param("userId") Long userId,
            @Param("revokedAt") Instant revokedAt,
            @Param("reason") AuthSessionRevocationReason reason);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("""
            UPDATE AuthSession session
            SET session.revokedAt = :revokedAt,
                session.revocationReason = :reason
            WHERE session.user.id = :userId
              AND session.id <> :currentSessionId
              AND session.revokedAt IS NULL
            """)
    int revokeOtherActiveByUserId(
            @Param("userId") Long userId,
            @Param("currentSessionId") UUID currentSessionId,
            @Param("revokedAt") Instant revokedAt,
            @Param("reason") AuthSessionRevocationReason reason);
}
