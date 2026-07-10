package com.elvencode.productportal.access.assignment.audit.repository;

import com.elvencode.productportal.access.assignment.audit.entity.UserRoleAssignmentAudit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserRoleAssignmentAuditRepository extends JpaRepository<UserRoleAssignmentAudit, Long> {

    List<UserRoleAssignmentAudit> findByUserIdAndOrganizationIdAndRoleCodeOrderByChangedAtDesc(
            Long userId,
            Long organizationId,
            String roleCode);
}
