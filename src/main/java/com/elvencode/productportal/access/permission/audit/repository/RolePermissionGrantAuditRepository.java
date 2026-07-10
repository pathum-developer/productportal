package com.elvencode.productportal.access.permission.audit.repository;

import com.elvencode.productportal.access.permission.audit.entity.RolePermissionGrantAudit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RolePermissionGrantAuditRepository extends JpaRepository<RolePermissionGrantAudit, Long> {

    List<RolePermissionGrantAudit> findByRoleCodeAndPermissionCodeOrderByChangedAtDesc(
            String roleCode,
            String permissionCode);
}
