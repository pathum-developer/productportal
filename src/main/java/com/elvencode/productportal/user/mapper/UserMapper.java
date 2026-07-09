package com.elvencode.productportal.user.mapper;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.address.mapper.AddressMapper;
import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.dto.response.UserRegistrationResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

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
                toRoleResponse(portalUser.getRole()),
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
                toRoleResponse(portalUser.getRole()),
                toUserStatusResponse(portalUser.getStatus()),
                portalUser.getCreatedAt());
    }

    private RoleSummaryResponse toRoleResponse(Role role) {
        return new RoleSummaryResponse(
                role.getRoleCode(),
                role.getDisplayName(),
                role.getActive());
    }

    private UserReferenceResponse toUserStatusResponse(UserStatus userStatus) {
        return new UserReferenceResponse(
                userStatus.getStatusCode(),
                userStatus.getDisplayName(),
                userStatus.getActive());
    }
}
