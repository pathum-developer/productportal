package com.elvencode.productportal.access.permission.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
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
        name = "pp_m_permission",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_permission_display_name", columnNames = "display_name"),
                @UniqueConstraint(
                        name = "uk_pp_m_permission_resource_action",
                        columnNames = {"resource_code", "action_code"})
        },
        indexes = {
                @Index(name = "idx_pp_m_permission_active", columnList = "is_active")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Permission extends BaseEntity {

    @Id
    @NotBlank
    @Size(max = 80)
    @Column(name = "permission_code", nullable = false, length = 80, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private String permissionCode;

    @NotBlank
    @Size(max = 150)
    @Column(name = "display_name", nullable = false, length = 150)
    @ToString.Include
    private String displayName;

    @Size(max = 255)
    @Column(name = "description", length = 255)
    private String description;

    @NotBlank
    @Size(max = 60)
    @Column(name = "resource_code", nullable = false, length = 60)
    private String resourceCode;

    @NotBlank
    @Size(max = 60)
    @Column(name = "action_code", nullable = false, length = 60)
    private String actionCode;

    @NotNull
    @Positive
    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    @NotNull
    @Column(name = "is_active", nullable = false)
    private Boolean active = Boolean.TRUE;
}
