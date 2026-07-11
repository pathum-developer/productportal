package com.elvencode.productportal.auth.session.entity;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.common.persistence.BaseEntity;
import com.elvencode.productportal.user.entity.PortalUser;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
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
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter(AccessLevel.PROTECTED)
@Entity
@Table(
        name = "pp_t_auth_session",
        indexes = {
                @Index(name = "idx_pp_t_auth_session_user_active", columnList = "user_id, revoked_at, refresh_expires_at"),
                @Index(name = "idx_pp_t_auth_session_refresh_expires_at", columnList = "refresh_expires_at")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class AuthSession extends BaseEntity {

    @Id
    @JdbcTypeCode(SqlTypes.CHAR)
    @Column(name = "auth_session_id", nullable = false, updatable = false, length = 36, columnDefinition = "CHAR(36)")
    @EqualsAndHashCode.Include
    @ToString.Include
    private UUID id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_auth_session_user"))
    private PortalUser user;

    @NotBlank
    @Size(max = 64)
    @Column(name = "refresh_token_hash", nullable = false, length = 64)
    private String refreshTokenHash;

    @NotNull
    @Column(name = "issued_at", nullable = false)
    private Instant issuedAt;

    @NotNull
    @Column(name = "refresh_expires_at", nullable = false)
    private Instant refreshExpiresAt;

    @NotNull
    @Column(name = "last_used_at", nullable = false)
    private Instant lastUsedAt;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "revocation_reason", length = 60)
    private AuthSessionRevocationReason revocationReason;

    @Size(max = 45)
    @Column(name = "client_ip", length = 45)
    private String clientIp;

    @Size(max = 512)
    @Column(name = "user_agent", length = 512)
    private String userAgent;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    public static AuthSession create(
            UUID id,
            PortalUser user,
            String refreshTokenHash,
            Instant refreshExpiresAt,
            LoginRequestMetadata metadata,
            Instant now) {
        AuthSession session = new AuthSession();
        session.id = id;
        session.user = user;
        session.refreshTokenHash = refreshTokenHash;
        session.issuedAt = now;
        session.refreshExpiresAt = refreshExpiresAt;
        session.lastUsedAt = now;
        session.updateClientMetadata(metadata);
        return session;
    }

    public boolean isActive(Instant now) {
        return revokedAt == null && refreshExpiresAt.isAfter(now);
    }

    public boolean isValidForCredentials(Instant credentialsChangedAt) {
        return credentialsChangedAt == null || !issuedAt.isBefore(credentialsChangedAt);
    }

    public void rotateRefreshToken(
            String newRefreshTokenHash,
            Instant newRefreshExpiresAt,
            LoginRequestMetadata metadata,
            Instant now) {
        refreshTokenHash = newRefreshTokenHash;
        refreshExpiresAt = newRefreshExpiresAt;
        lastUsedAt = now;
        updateClientMetadata(metadata);
    }

    public void revoke(AuthSessionRevocationReason reason, Instant now) {
        if (revokedAt != null) {
            return;
        }

        revokedAt = now;
        revocationReason = reason;
    }

    private void updateClientMetadata(LoginRequestMetadata metadata) {
        LoginRequestMetadata safeMetadata = metadata == null ? LoginRequestMetadata.unknown() : metadata;
        clientIp = safeMetadata.clientIp();
        userAgent = safeMetadata.userAgent();
    }
}
