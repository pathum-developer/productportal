package com.elvencode.productportal.user.mapper;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;
import com.elvencode.productportal.organization.entity.Organization;
import com.elvencode.productportal.organization.membership.entity.UserOrganizationMembership;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.address.mapper.AddressMapper;
import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.dto.response.UserMembershipResponse;
import com.elvencode.productportal.user.dto.response.UserRoleAssignmentResponse;
import com.elvencode.productportal.user.dto.response.UserRegistrationResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Comparator;

@Component
@RequiredArgsConstructor
public class UserMapper {

    private final AddressMapper addressMapper;

    public UserDetailsResponse toDetailsResponse(PortalUser portalUser) {
        List<AddressResponse> addresses = portalUser.getAddresses()
                .stream()
                .map(addressMapper::toResponse)
                .toList();

        return new UserDetailsResponse(
                portalUser.getId(),
                portalUser.getUsername(),
                portalUser.getFullName(),
                portalUser.getEmail(),
                portalUser.getPhoneNumber(),
                toOrganizationResponse(portalUser.getPrimaryOrganization()),
                toRoleResponses(portalUser),
                toRoleAssignmentResponses(portalUser),
                toMembershipResponses(portalUser),
                toUserStatusResponse(portalUser.getStatus()),
                addresses,
                portalUser.getVersion(),
                portalUser.getCreatedAt(),
                portalUser.getCreatedBy(),
                portalUser.getUpdatedAt(),
                portalUser.getUpdatedBy());
    }

    public UserRegistrationResponse toRegistrationResponse(PortalUser portalUser) {
        return new UserRegistrationResponse(
                portalUser.getId(),
                portalUser.getUsername(),
                portalUser.getFullName(),
                portalUser.getEmail(),
                portalUser.getPhoneNumber(),
                toOrganizationResponse(portalUser.getPrimaryOrganization()),
                toRoleResponses(portalUser),
                toMembershipResponses(portalUser),
                toUserStatusResponse(portalUser.getStatus()),
                portalUser.getCreatedAt());
    }

    private List<RoleSummaryResponse> toRoleResponses(PortalUser portalUser) {
        return portalUser.getRoles()
                .stream()
                .map(this::toRoleResponse)
                .toList();
    }

    private List<UserRoleAssignmentResponse> toRoleAssignmentResponses(PortalUser portalUser) {
        return portalUser.getActiveRoleAssignments()
                .stream()
                .map(this::toRoleAssignmentResponse)
                .toList();
    }

    private UserRoleAssignmentResponse toRoleAssignmentResponse(UserRoleAssignment assignment) {
        return new UserRoleAssignmentResponse(
                toRoleResponse(assignment.getRole()),
                toOrganizationResponse(assignment.getOrganization()),
                assignment.getActive(),
                assignment.getValidFrom(),
                assignment.getValidUntil(),
                assignment.getAssignedBy(),
                assignment.getAssignedReason());
    }

    private List<UserMembershipResponse> toMembershipResponses(PortalUser portalUser) {
        return portalUser.getMemberships()
                .stream()
                .sorted(Comparator
                        .comparing(UserOrganizationMembership::getPrimaryMembership).reversed()
                        .thenComparing(membership -> membership.getOrganization().getDisplayName()))
                .map(this::toMembershipResponse)
                .toList();
    }

    private UserMembershipResponse toMembershipResponse(UserOrganizationMembership membership) {
        return new UserMembershipResponse(
                toOrganizationResponse(membership.getOrganization()),
                toMembershipStatusResponse(membership),
                membership.getPrimaryMembership(),
                membership.getJoinedAt());
    }

    private RoleSummaryResponse toRoleResponse(Role role) {
        return new RoleSummaryResponse(
                role.getRoleCode(),
                role.getDisplayName(),
                role.getActive());
    }

    private OrganizationSummaryResponse toOrganizationResponse(Organization organization) {
        if (organization == null) {
            return null;
        }
        return new OrganizationSummaryResponse(
                organization.getId(),
                organization.getOrganizationCode(),
                organization.getDisplayName(),
                organization.getActive());
    }

    private UserReferenceResponse toMembershipStatusResponse(UserOrganizationMembership membership) {
        return new UserReferenceResponse(
                membership.getMembershipStatus().getStatusCode(),
                membership.getMembershipStatus().getDisplayName(),
                membership.getMembershipStatus().getActive());
    }

    private UserReferenceResponse toUserStatusResponse(UserStatus userStatus) {
        return new UserReferenceResponse(
                userStatus.getStatusCode(),
                userStatus.getDisplayName(),
                userStatus.getActive());
    }
}
