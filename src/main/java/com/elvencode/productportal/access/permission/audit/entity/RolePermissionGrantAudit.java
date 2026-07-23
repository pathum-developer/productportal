package com.elvencode.productportal.access.permission.audit.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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

import java.time.Instant;

@Getter
@Setter(AccessLevel.PROTECTED)
@Entity
@Immutable
@Table(
        name = "pp_t_role_permission_grant_audit",
        indexes = {
                @Index(
                        name = "idx_pp_t_role_permission_grant_audit_role_time",
                        columnList = "role_code, changed_at"),
                @Index(
                        name = "idx_pp_t_role_permission_grant_audit_permission_time",
                        columnList = "permission_code, changed_at"),
                @Index(
                        name = "idx_pp_t_role_permission_grant_audit_event_time",
                        columnList = "event_type, changed_at"),
                @Index(
                        name = "idx_pp_t_role_permission_grant_audit_correlation_id",
                        columnList = "correlation_id"),
                @Index(name = "idx_pp_t_role_permission_grant_audit_assigned_by", columnList = "assigned_by"),
                @Index(name = "idx_pp_t_role_permission_grant_audit_revoked_by", columnList = "revoked_by")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(onlyExplicitlyIncluded = true)
public class RolePermissionGrantAudit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "audit_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long auditId;

    @NotBlank
    @Size(max = 30)
    @Column(name = "role_code", nullable = false, length = 30)
    private String roleCode;

    @NotBlank
    @Size(max = 80)
    @Column(name = "permission_code", nullable = false, length = 80)
    private String permissionCode;

    @NotBlank
    @Size(max = 30)
    @Column(name = "event_type", nullable = false, length = 30)
    private String eventType;

    @Column(name = "previous_active")
    private Boolean previousActive;

    @Column(name = "new_active")
    private Boolean newActive;

    @Size(max = 100)
    @Column(name = "assigned_by", length = 100)
    private String assignedBy;

    @Size(max = 255)
    @Column(name = "assigned_reason", length = 255)
    private String assignedReason;

    @Size(max = 100)
    @Column(name = "revoked_by", length = 100)
    private String revokedBy;

    @Size(max = 255)
    @Column(name = "revoked_reason", length = 255)
    private String revokedReason;

    @NotNull
    @Column(name = "changed_at", nullable = false)
    private Instant changedAt;

    @NotBlank
    @Size(max = 100)
    @Column(name = "changed_by", nullable = false, length = 100)
    private String changedBy;

    @NotBlank
    @Size(max = 100)
    @Column(name = "database_user", nullable = false, length = 100)
    private String databaseUser;

    @NotBlank
    @Size(max = 30)
    @Column(name = "source_code", nullable = false, length = 30)
    private String sourceCode;

    @Size(max = 255)
    @Column(name = "change_reason", length = 255)
    private String changeReason;

    @Size(max = 100)
    @Column(name = "correlation_id", length = 100)
    private String correlationId;
}
