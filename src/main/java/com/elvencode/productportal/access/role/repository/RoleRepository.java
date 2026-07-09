package com.elvencode.productportal.access.role.repository;

import com.elvencode.productportal.access.role.entity.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, String> {

    List<Role> findByActiveTrueOrderBySortOrderAsc();

    Optional<Role> findRoleByRoleCode(String roleCode);
}
