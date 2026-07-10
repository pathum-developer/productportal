package com.elvencode.productportal.organization.membership.repository;

import com.elvencode.productportal.organization.membership.entity.UserOrganizationMembership;
import com.elvencode.productportal.organization.membership.entity.UserOrganizationMembershipId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserOrganizationMembershipRepository
        extends JpaRepository<UserOrganizationMembership, UserOrganizationMembershipId> {

    List<UserOrganizationMembership> findByUser_Id(Long userId);

    List<UserOrganizationMembership> findByOrganization_Id(Long organizationId);
}
