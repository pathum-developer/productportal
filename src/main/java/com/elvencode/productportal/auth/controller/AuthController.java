package com.elvencode.productportal.auth.controller;

import com.elvencode.productportal.auth.dto.request.LoginRequest;
import com.elvencode.productportal.auth.dto.request.LogoutRequest;
import com.elvencode.productportal.auth.dto.request.RefreshTokenRequest;
import com.elvencode.productportal.auth.dto.response.LoginResponse;
import com.elvencode.productportal.auth.dto.response.TokenRefreshResponse;
import com.elvencode.productportal.auth.protection.web.LoginRequestMetadataResolver;
import com.elvencode.productportal.auth.service.AuthService;
import com.elvencode.productportal.common.dto.ErrorResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/auth", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
@Tag(name = "Authentication", description = "Token-based authentication APIs")
public class AuthController {

    private final AuthService authService;
    private final LoginRequestMetadataResolver metadataResolver;

    @Operation(
            summary = "Authenticate user",
            description = """
                    Authenticates a user and returns a short-lived bearer token with organization, role,
                    and permission context resolved from active RBAC assignments.
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Authentication successful",
                    content = @Content(schema = @Schema(implementation = LoginResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid login request",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Invalid credentials or inactive account",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @PostMapping(path = "/login", consumes = MediaType.APPLICATION_JSON_VALUE, version = "1.0")
    public ResponseEntity<LoginResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.PRAGMA, "no-cache")
                .body(authService.login(request, metadataResolver.resolve(httpRequest)));
    }

    @Operation(
            summary = "Refresh authentication tokens",
            description = "Rotates a refresh token and returns a new short-lived bearer token."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Token refresh successful",
                    content = @Content(schema = @Schema(implementation = TokenRefreshResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid refresh request",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Invalid refresh token",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @PostMapping(path = "/refresh", consumes = MediaType.APPLICATION_JSON_VALUE, version = "1.0")
    public ResponseEntity<TokenRefreshResponse> refresh(
            @Valid @RequestBody RefreshTokenRequest request,
            HttpServletRequest httpRequest) {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.PRAGMA, "no-cache")
                .body(authService.refresh(request, metadataResolver.resolve(httpRequest)));
    }

    @Operation(
            summary = "Logout",
            description = "Revokes the refresh-token session represented by the supplied refresh token."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Logout processed"),
            @ApiResponse(responseCode = "400", description = "Invalid logout request", content = @Content)
    })
    @PostMapping(path = "/logout", consumes = MediaType.APPLICATION_JSON_VALUE, version = "1.0")
    public ResponseEntity<Void> logout(@Valid @RequestBody LogoutRequest request) {
        authService.logout(request);
        return ResponseEntity.noContent()
                .cacheControl(CacheControl.noStore())
                .header(HttpHeaders.PRAGMA, "no-cache")
                .build();
    }
}
