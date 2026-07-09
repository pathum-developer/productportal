package com.elvencode.productportal.auth.dto.response;

import java.util.List;

public record LoginResponse(
        String tokenType,
        String accessToken,
        Long expiresInSeconds,
        String username,
        List<String> roles
) {
}
