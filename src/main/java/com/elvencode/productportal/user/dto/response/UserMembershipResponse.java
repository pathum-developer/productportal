package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;
import com.elvencode.productportal.user.reference.dto.UserReferenceResponse;

import java.time.Instant;

public record UserMembershipResponse(
        OrganizationSummaryResponse organization,
        UserReferenceResponse status,
        Boolean primary,
        Instant joinedAt
) {
}
