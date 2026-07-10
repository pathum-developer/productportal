package com.elvencode.productportal.user.controller;

import com.elvencode.productportal.common.dto.ErrorResponseDto;
import com.elvencode.productportal.user.dto.request.UserRegistrationRequest;
import com.elvencode.productportal.user.dto.response.UserDetailsResponse;
import com.elvencode.productportal.user.dto.response.UserRegistrationResponse;
import com.elvencode.productportal.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;

@RestController
@RequestMapping(path = "/users", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
@Tag(name = "Users", description = "User account APIs")
public class UserController {

    private final UserService userService;

    @Operation(
            summary = "Register user",
            description = "Creates an ACTIVE user account with a primary organization membership and default role assignment."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "201",
                    description = "User registered",
                    content = @Content(schema = @Schema(implementation = UserRegistrationResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid registration request",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "Username, email, or phone number already exists",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @PostMapping(path = "/register", consumes = MediaType.APPLICATION_JSON_VALUE, version = "1.0")
    public ResponseEntity<UserRegistrationResponse> registerUser(
            @Valid @RequestBody UserRegistrationRequest request) {
        UserRegistrationResponse response = userService.registerUser(request);
        URI location = ServletUriComponentsBuilder
                .fromCurrentContextPath()
                .path("/api/users/username/{username}")
                .buildAndExpand(response.username())
                .toUri();

        return ResponseEntity.created(location).body(response);
    }

    @Operation(
            summary = "Get user details by username",
            description = "Returns user account details with organization memberships, role assignments, status, audit metadata, and all addresses."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "User found",
                    content = @Content(schema = @Schema(implementation = UserDetailsResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid username",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "User not found",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @GetMapping(path = "/username/{username}", version = "1.0")
    public ResponseEntity<UserDetailsResponse> getUserDetailsByUsername(
            @Parameter(description = "Unique username", example = "amal.perera", required = true)
            @PathVariable
            @NotBlank(message = "Username is required")
            @Size(max = 100, message = "Username must be at most 100 characters")
            String username) {
        return ResponseEntity.ok(userService.getUserDetailsByUsername(username));
    }

    @Operation(
            summary = "Get users by status with custom sorting and pagination",
            description = """
                    Retrieve paginated users filtered by status code with flexible sorting.
                    
                    **Sortable Columns:** username, fullName, email, phoneNumber, createdAt, updatedAt, status
                    
                    **Sort Examples:**
                    - `?sort=username,desc` (default) - Sort by username descending
                    - `?sort=email,asc` - Sort by email ascending
                    - `?sort=createdAt,desc` - Sort by created date descending
                    - `?sort=fullName,asc` - Sort by full name ascending
                    
                    **Invalid columns are ignored; defaults to username DESC.**
                    All sort parameters are validated server-side to prevent SQL injection.
                    """
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Paginated users matching status",
                    content = @Content(schema = @Schema(implementation = org.springframework.data.domain.Page.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid status or pagination parameters",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @GetMapping(path = "/status/{status}", version = "1.0")
    public ResponseEntity<org.springframework.data.domain.Page<UserDetailsResponse>> getAllUsersByStatus(
            @Parameter(description = "Status code (e.g., ACTIVE, INACTIVE)", example = "ACTIVE", required = true)
            @PathVariable
            @NotBlank(message = "Status is required")
            String status,
            @Parameter(description = "Pagination & sort params. Default: page=0, size=20, sort=username,desc. " +
                    "Sortable columns: username, fullName, email, phoneNumber, createdAt, updatedAt, status. " +
                    "Example: ?page=0&size=10&sort=email,asc")
            Pageable pageable) {
        return ResponseEntity.ok().body(userService.getAllUsersByStatus(status, pageable));
    }


}
