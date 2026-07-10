package com.elvencode.productportal.organization.membership.audit.repository;

import com.elvencode.productportal.organization.membership.audit.entity.UserOrganizationMembershipAudit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserOrganizationMembershipAuditRepository
        extends JpaRepository<UserOrganizationMembershipAudit, Long> {

    List<UserOrganizationMembershipAudit> findByUserIdAndOrganizationIdOrderByChangedAtDesc(
            Long userId,
            Long organizationId);
}
