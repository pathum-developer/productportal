package com.elvencode.productportal.access.role.dto.response;

public record RoleSummaryResponse(
        String code,
        String displayName,
        Boolean active
) {
}
