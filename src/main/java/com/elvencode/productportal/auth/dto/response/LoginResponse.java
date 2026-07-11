package com.elvencode.productportal.auth.dto.response;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record LoginResponse(
        String tokenType,
        String accessToken,
        String refreshToken,
        UUID sessionId,
        Instant issuedAt,
        Instant expiresAt,
        Long expiresInSeconds,
        Instant refreshExpiresAt,
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
