package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;

import java.time.Instant;
import java.util.List;

public record UserDetailsResponse(
        Long id,
        String username,
        String fullName,
        String email,
        String phoneNumber,
        RoleSummaryResponse role,
        UserReferenceResponse status,
        List<AddressResponse> addresses,
        Long version,
        Instant createdAt,
        String createdBy,
        Instant updatedAt,
        String updatedBy
) {
}
