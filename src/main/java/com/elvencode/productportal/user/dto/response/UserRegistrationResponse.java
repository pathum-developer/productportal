package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;

import java.time.Instant;

public record UserRegistrationResponse(
        Long id,
        String username,
        String fullName,
        String email,
        String phoneNumber,
        RoleSummaryResponse role,
        UserReferenceResponse status,
        Instant createdAt
) {
}
