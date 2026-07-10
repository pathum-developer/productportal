package com.elvencode.productportal.user.dto.response;

public record UserSummaryResponse(
        Long id,
        String username,
        String fullName
) {
}
