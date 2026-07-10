package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;
import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;

import java.time.Instant;

public record UserRoleAssignmentResponse(
        RoleSummaryResponse role,
        OrganizationSummaryResponse organization,
        Boolean active,
        Instant validFrom,
        Instant validUntil,
        String assignedBy,
        String assignedReason
) {
}
