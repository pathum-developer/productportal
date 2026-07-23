package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;

import java.time.Instant;
import java.util.List;

public record UserRegistrationResponse(
        Long id,
        String username,
        String fullName,
        String email,
        String phoneNumber,
        OrganizationSummaryResponse organization,
        List<RoleSummaryResponse> roles,
        UserReferenceResponse status,
        Instant createdAt
) {
}
