package com.elvencode.productportal.user.dto.response;

import com.elvencode.productportal.access.role.dto.response.RoleSummaryResponse;

import java.time.Instant;

public record UserRoleAssignmentResponse(
        RoleSummaryResponse role,
        Boolean active,
        Instant validFrom,
        Instant validUntil,
        String assignedBy,
        String assignedReason
) {
}
