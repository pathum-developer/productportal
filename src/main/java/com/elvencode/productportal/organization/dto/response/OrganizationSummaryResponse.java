package com.elvencode.productportal.organization.dto.response;

public record OrganizationSummaryResponse(
        Long id,
        String organizationCode,
        String displayName,
        Boolean active
) {
}
