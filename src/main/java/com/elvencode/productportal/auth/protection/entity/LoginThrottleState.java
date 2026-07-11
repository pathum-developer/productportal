package com.elvencode.productportal.auth.protection.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.persistence.Version;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.time.Duration;
import java.time.Instant;

@Getter
@Setter
@Entity
@Table(
        name = "pp_t_login_throttle_state",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_pp_t_login_throttle_state_scope_identifier",
                        columnNames = {"scope", "identifier_value"})
        },
        indexes = {
                @Index(
                        name = "idx_pp_t_login_throttle_state_scope_locked_until",
                        columnList = "scope, locked_until"),
                @Index(
                        name = "idx_pp_t_login_throttle_state_identifier",
                        columnList = "identifier_value")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class LoginThrottleState extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "throttle_state_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "scope", nullable = false, length = 30)
    @ToString.Include
    private LoginThrottleScope scope;

    @NotBlank
    @Size(max = 255)
    @Column(name = "identifier_value", nullable = false, length = 255)
    @ToString.Include
    private String identifier;

    @NotNull
    @Column(name = "failed_attempt_count", nullable = false)
    private Integer failedAttemptCount = 0;

    @Column(name = "window_started_at")
    private Instant windowStartedAt;

    @Column(name = "last_failed_at")
    private Instant lastFailedAt;

    @Column(name = "locked_until")
    private Instant lockedUntil;

    @Column(name = "last_successful_at")
    private Instant lastSuccessfulAt;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    public static LoginThrottleState create(LoginThrottleScope scope, String identifier) {
        LoginThrottleState state = new LoginThrottleState();
        state.scope = scope;
        state.identifier = identifier;
        state.failedAttemptCount = 0;
        return state;
    }

    public boolean isLocked(Instant now) {
        return lockedUntil != null && lockedUntil.isAfter(now);
    }

    public void recordFailure(
            Instant now,
            int maxFailedAttempts,
            Duration failureWindow,
            Duration lockDuration) {
        if (windowStartedAt == null || !windowStartedAt.plus(failureWindow).isAfter(now)) {
            failedAttemptCount = 0;
            windowStartedAt = now;
            lockedUntil = null;
        }

        failedAttemptCount++;
        lastFailedAt = now;

        if (failedAttemptCount >= maxFailedAttempts) {
            lockedUntil = now.plus(lockDuration);
        }
    }

    public void recordSuccessfulUsernameLogin(Instant now) {
        failedAttemptCount = 0;
        windowStartedAt = null;
        lockedUntil = null;
        lastSuccessfulAt = now;
    }

    public void recordSuccessfulIpLogin(Instant now) {
        lastSuccessfulAt = now;
    }
}
