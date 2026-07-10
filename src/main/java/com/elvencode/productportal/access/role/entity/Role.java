package com.elvencode.productportal.access.role.entity;

import com.elvencode.productportal.common.persistence.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
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
@Setter(AccessLevel.PROTECTED)
@Entity
@Table(
        name = "pp_m_role",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_pp_m_role_display_name", columnNames = "display_name")
        }
)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EqualsAndHashCode(onlyExplicitlyIncluded = true, callSuper = false)
@ToString(onlyExplicitlyIncluded = true)
public class Role extends BaseEntity {

    @Id
    @NotBlank
    @Size(max = 30)
    @Column(name = "role_code", nullable = false, length = 30, updatable = false)
    @EqualsAndHashCode.Include
    @ToString.Include
    private String roleCode;

    @NotBlank
    @Size(max = 100)
    @Column(name = "display_name", nullable = false, length = 100)
    @ToString.Include
    private String displayName;

    @Size(max = 255)
    @Column(name = "description", length = 255)
    private String description;

    @NotNull
    @Positive
    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder;

    @NotNull
    @Column(name = "is_active", nullable = false)
    private Boolean active = Boolean.TRUE;

    public static Role create(String roleCode, String displayName, String description, Integer sortOrder) {
        Role role = new Role();
        role.roleCode = roleCode;
        role.displayName = displayName;
        role.description = description;
        role.sortOrder = sortOrder;
        role.active = Boolean.TRUE;
        return role;
    }

    public void updateDetails(String displayName, String description, Integer sortOrder) {
        this.displayName = displayName;
        this.description = description;
        this.sortOrder = sortOrder;
    }

    public void activate() {
        this.active = Boolean.TRUE;
    }

    public void deactivate() {
        this.active = Boolean.FALSE;
    }
}
