package com.elvencode.productportal.auth.dto.response;

import java.time.Instant;
import java.util.List;

public record LoginResponse(
        String tokenType,
        String accessToken,
        Instant issuedAt,
        Instant expiresAt,
        Long expiresInSeconds,
        AuthenticatedUserResponse user,
        AccessContextResponse access
) {

    public record AuthenticatedUserResponse(
            Long userId,
            String username,
            String statusCode,
            Long primaryOrganizationId
    ) {
    }

    public record AccessContextResponse(
            List<String> roleCodes,
            List<String> permissionCodes
    ) {
        public AccessContextResponse {
            roleCodes = roleCodes == null ? List.of() : List.copyOf(roleCodes);
            permissionCodes = permissionCodes == null ? List.of() : List.copyOf(permissionCodes);
        }
    }
}
