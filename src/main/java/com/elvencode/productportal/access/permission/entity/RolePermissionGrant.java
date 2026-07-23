package com.elvencode.productportal.access.permission.entity;

import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
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

@Getter
@Setter
@Entity
@Table(
        name = "pp_t_role_permission_grant",
        indexes = {
                @Index(name = "idx_pp_t_role_permission_grant_permission_code", columnList = "permission_code"),
                @Index(name = "idx_pp_t_role_permission_grant_role_active", columnList = "role_code, is_active"),
                @Index(
                        name = "idx_pp_t_role_permission_grant_permission_active",
                        columnList = "permission_code, is_active"),
                @Index(name = "idx_pp_t_role_permission_grant_assigned_by", columnList = "assigned_by"),
                @Index(name = "idx_pp_t_role_permission_grant_revoked_by", columnList = "revoked_by")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class RolePermissionGrant extends BaseEntity {

    @EmbeddedId
    @EqualsAndHashCode.Include
    private RolePermissionGrantId id = new RolePermissionGrantId();

    @NotNull
    @MapsId("roleCode")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "role_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_role_permission_grant_role"))
    private Role role;

    @NotNull
    @MapsId("permissionCode")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "permission_code",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_pp_t_role_permission_grant_permission"))
    private Permission permission;

    @NotNull
    @Column(name = "is_active", nullable = false)
    private Boolean active = Boolean.TRUE;

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

    public boolean isCurrentlyActive() {
        return Boolean.TRUE.equals(active)
                && role != null
                && Boolean.TRUE.equals(role.getActive())
                && permission != null
                && Boolean.TRUE.equals(permission.getActive());
    }
}
