package com.elvencode.productportal.auth.protection.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AccessLevel;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.Immutable;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.Instant;

@Getter
@Setter(AccessLevel.PROTECTED)
@Entity
@Immutable
@EntityListeners(AuditingEntityListener.class)
@Table(
        name = "pp_a_login_attempt",
        indexes = {
                @Index(name = "idx_pp_a_login_attempt_username_time", columnList = "username, occurred_at"),
                @Index(name = "idx_pp_a_login_attempt_client_ip_time", columnList = "client_ip, occurred_at"),
                @Index(name = "idx_pp_a_login_attempt_outcome_time", columnList = "outcome, occurred_at"),
                @Index(name = "idx_pp_a_login_attempt_user_id_time", columnList = "user_id, occurred_at")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(onlyExplicitlyIncluded = true)
public class LoginAttemptAudit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "login_attempt_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long id;

    @NotBlank
    @Size(max = 100)
    @Column(name = "username", nullable = false, length = 100)
    @ToString.Include
    private String username;

    @Column(name = "user_id")
    private Long userId;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "outcome", nullable = false, length = 40)
    @ToString.Include
    private LoginAttemptOutcome outcome;

    @Size(max = 45)
    @Column(name = "client_ip", length = 45)
    private String clientIp;

    @Size(max = 512)
    @Column(name = "user_agent", length = 512)
    private String userAgent;

    @Column(name = "locked_until")
    private Instant lockedUntil;

    @NotNull
    @Column(name = "occurred_at", nullable = false)
    @ToString.Include
    private Instant occurredAt;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @CreatedBy
    @Column(name = "created_by", nullable = false, length = 100, updatable = false)
    private String createdBy;

    public static LoginAttemptAudit create(
            String username,
            Long userId,
            LoginAttemptOutcome outcome,
            String clientIp,
            String userAgent,
            Instant lockedUntil,
            Instant occurredAt) {
        LoginAttemptAudit audit = new LoginAttemptAudit();
        audit.username = username;
        audit.userId = userId;
        audit.outcome = outcome;
        audit.clientIp = clientIp;
        audit.userAgent = userAgent;
        audit.lockedUntil = lockedUntil;
        audit.occurredAt = occurredAt;
        return audit;
    }
}
