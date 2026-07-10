package com.elvencode.productportal.access.assignment.repository;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.assignment.entity.UserRoleAssignmentId;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRoleAssignmentRepository extends JpaRepository<UserRoleAssignment, UserRoleAssignmentId> {

    @EntityGraph(attributePaths = {"role", "organization", "membership.membershipStatus"})
    List<UserRoleAssignment> findByUser_IdAndActiveTrue(Long userId);

    @EntityGraph(attributePaths = {"role", "organization", "membership.membershipStatus"})
    List<UserRoleAssignment> findByOrganization_IdAndRole_RoleCodeAndActiveTrue(
            Long organizationId,
            String roleCode);
}
