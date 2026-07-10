package com.elvencode.productportal.access.permission.repository;

import com.elvencode.productportal.access.permission.entity.Permission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PermissionRepository extends JpaRepository<Permission, String> {

    Optional<Permission> findByPermissionCode(String permissionCode);

    List<Permission> findByActiveTrueOrderBySortOrderAsc();
}
