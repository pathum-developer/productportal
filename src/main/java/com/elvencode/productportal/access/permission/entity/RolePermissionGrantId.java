package com.elvencode.productportal.access.permission.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class RolePermissionGrantId implements Serializable {

    @Column(name = "role_code", nullable = false, length = 30)
    private String roleCode;

    @Column(name = "permission_code", nullable = false, length = 80)
    private String permissionCode;
}
