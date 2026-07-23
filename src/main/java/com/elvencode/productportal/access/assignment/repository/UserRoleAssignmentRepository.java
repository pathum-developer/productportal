package com.elvencode.productportal.access.assignment.repository;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.assignment.entity.UserRoleAssignmentId;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface UserRoleAssignmentRepository extends JpaRepository<UserRoleAssignment, UserRoleAssignmentId> {

    @EntityGraph(attributePaths = {"role"})
    List<UserRoleAssignment> findByUser_IdAndActiveTrue(Long userId);

    @EntityGraph(attributePaths = {"role", "user", "user.organization"})
    @Query("""
            SELECT assignment
            FROM UserRoleAssignment assignment
            JOIN assignment.user portalUser
            JOIN portalUser.organization organization
            WHERE organization.id = :organizationId
              AND assignment.role.roleCode = :roleCode
              AND assignment.active = TRUE
            """)
    List<UserRoleAssignment> findActiveByUserOrganizationIdAndRoleCode(
            @Param("organizationId") Long organizationId,
            @Param("roleCode") String roleCode);
}
