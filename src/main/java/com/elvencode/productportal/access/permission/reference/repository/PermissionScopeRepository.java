package com.elvencode.productportal.access.permission.reference.repository;

import com.elvencode.productportal.access.permission.reference.entity.PermissionScope;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PermissionScopeRepository extends JpaRepository<PermissionScope, String> {

    List<PermissionScope> findByActiveTrueOrderBySortOrderAsc();
}
