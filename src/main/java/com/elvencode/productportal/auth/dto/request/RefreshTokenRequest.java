package com.elvencode.productportal.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RefreshTokenRequest(
        @NotBlank(message = "Refresh token is required")
        @Size(max = 512, message = "Refresh token must be at most 512 characters")
        String refreshToken
) {
}
