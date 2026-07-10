package com.elvencode.productportal.access.assignment.entity;

import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.common.persistence.BaseEntity;
import com.elvencode.productportal.organization.entity.Organization;
import com.elvencode.productportal.organization.membership.entity.UserOrganizationMembership;
import com.elvencode.productportal.user.entity.PortalUser;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapsId;
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

import java.time.Instant;

@Getter
@Setter
@Entity
@Table(
        name = "pp_t_user_role_assignment",
        indexes = {
                @Index(name = "idx_pp_t_user_role_assignment_role_code", columnList = "role_code"),
                @Index(
                        name = "idx_pp_t_user_role_assignment_user_org_active_validity",
                        columnList = "user_id, organization_id, is_active, valid_from, valid_until"),
                @Index(
                        name = "idx_pp_t_user_role_assignment_org_role_active",
                        columnList = "organization_id, role_code, is_active"),
                @Index(name = "idx_pp_t_user_role_assignment_role_active", columnList = "role_code, is_active"),
                @Index(name = "idx_pp_t_user_role_assignment_assigned_by", columnList = "assigned_by"),
                @Index(name = "idx_pp_t_user_role_assignment_revoked_by", columnList = "revoked_by")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class UserRoleAssignment extends BaseEntity {

    @EmbeddedId
    @EqualsAndHashCode.Include
    private UserRoleAssignmentId id = new UserRoleAssignmentId();

    @NotNull
    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_role_assignment_user"))
    private PortalUser user;

    @NotNull
    @MapsId("organizationId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "organization_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_role_assignment_organization"))
    private Organization organization;

    @NotNull
    @MapsId("roleCode")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "role_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_user_role_assignment_role"))
    private Role role;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumns(
            value = {
                    @JoinColumn(
                            name = "user_id",
                            referencedColumnName = "user_id",
                            insertable = false,
                            updatable = false,
                            nullable = false),
                    @JoinColumn(
                            name = "organization_id",
                            referencedColumnName = "organization_id",
                            insertable = false,
                            updatable = false,
                            nullable = false)
            },
            foreignKey = @ForeignKey(name = "fk_pp_t_user_role_assignment_membership")
    )
    private UserOrganizationMembership membership;

    @NotNull
    @Column(name = "is_active", nullable = false)
    private Boolean active = Boolean.TRUE;

    @Column(name = "valid_from")
    private Instant validFrom;

    @Column(name = "valid_until")
    private Instant validUntil;

    @NotBlank
    @Size(max = 100)
    @Column(name = "assigned_by", nullable = false, length = 100)
    private String assignedBy = "SYSTEM";

    @Size(max = 255)
    @Column(name = "assigned_reason", length = 255)
    private String assignedReason;

    @Size(max = 100)
    @Column(name = "revoked_by", length = 100)
    private String revokedBy;

    @Size(max = 255)
    @Column(name = "revoked_reason", length = 255)
    private String revokedReason;

    public static UserRoleAssignment assign(
            PortalUser user,
            Organization organization,
            Role role,
            UserOrganizationMembership membership,
            String assignedBy,
            String assignedReason) {
        UserRoleAssignment assignment = new UserRoleAssignment();
        assignment.id = new UserRoleAssignmentId(
                user.getId(),
                organization.getId(),
                role.getRoleCode());
        assignment.user = user;
        assignment.organization = organization;
        assignment.role = role;
        assignment.membership = membership;
        assignment.active = Boolean.TRUE;
        assignment.assignedBy = assignedBy;
        assignment.assignedReason = assignedReason;
        return assignment;
    }

    public boolean isCurrentlyActive(Instant now) {
        return Boolean.TRUE.equals(active)
                && role != null
                && Boolean.TRUE.equals(role.getActive())
                && membership != null
                && membership.isActiveMembership()
                && (validFrom == null || !validFrom.isAfter(now))
                && (validUntil == null || validUntil.isAfter(now));
    }
}
