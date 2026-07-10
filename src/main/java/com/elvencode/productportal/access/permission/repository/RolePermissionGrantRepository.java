package com.elvencode.productportal.access.permission.repository;

import com.elvencode.productportal.access.permission.entity.RolePermissionGrant;
import com.elvencode.productportal.access.permission.entity.RolePermissionGrantId;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface RolePermissionGrantRepository extends JpaRepository<RolePermissionGrant, RolePermissionGrantId> {

    @EntityGraph(attributePaths = {"role", "permission", "scope"})
    List<RolePermissionGrant> findByRole_RoleCodeAndActiveTrue(String roleCode);

    @EntityGraph(attributePaths = {"role", "permission", "scope"})
    List<RolePermissionGrant> findByRole_RoleCodeInAndActiveTrue(Collection<String> roleCodes);

    @EntityGraph(attributePaths = {"role", "permission", "scope"})
    List<RolePermissionGrant> findByPermission_PermissionCodeAndActiveTrue(String permissionCode);
}
