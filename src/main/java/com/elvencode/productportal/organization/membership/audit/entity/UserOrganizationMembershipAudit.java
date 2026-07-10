package com.elvencode.productportal.organization.membership.audit.entity;

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
        name = "pp_t_user_organization_membership_audit",
        indexes = {
                @Index(
                        name = "idx_pp_t_user_organization_membership_audit_user_org_time",
                        columnList = "user_id, organization_id, changed_at"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_audit_org_time",
                        columnList = "organization_id, changed_at"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_audit_event_time",
                        columnList = "event_type, changed_at"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_audit_correlation_id",
                        columnList = "correlation_id"),
                @Index(
                        name = "idx_pp_t_user_organization_membership_audit_changed_by",
                        columnList = "changed_by")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@ToString(onlyExplicitlyIncluded = true)
public class UserOrganizationMembershipAudit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "audit_id", nullable = false, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private Long auditId;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @NotNull
    @Column(name = "organization_id", nullable = false)
    private Long organizationId;

    @NotBlank
    @Size(max = 30)
    @Column(name = "event_type", nullable = false, length = 30)
    private String eventType;

    @Size(max = 30)
    @Column(name = "previous_membership_status", length = 30)
    private String previousMembershipStatus;

    @Size(max = 30)
    @Column(name = "new_membership_status", length = 30)
    private String newMembershipStatus;

    @Column(name = "previous_primary")
    private Boolean previousPrimary;

    @Column(name = "new_primary")
    private Boolean newPrimary;

    @Column(name = "previous_joined_at")
    private Instant previousJoinedAt;

    @Column(name = "new_joined_at")
    private Instant newJoinedAt;

    @Size(max = 100)
    @Column(name = "previous_invited_by", length = 100)
    private String previousInvitedBy;

    @Size(max = 100)
    @Column(name = "new_invited_by", length = 100)
    private String newInvitedBy;

    @Column(name = "previous_invited_at")
    private Instant previousInvitedAt;

    @Column(name = "new_invited_at")
    private Instant newInvitedAt;

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
