package com.elvencode.productportal.user.address.controller;

import com.elvencode.productportal.common.dto.ErrorResponseDto;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import com.elvencode.productportal.user.address.dto.request.AddressCreateRequest;
import com.elvencode.productportal.user.address.dto.response.AddressResponse;
import com.elvencode.productportal.user.address.service.AddressService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping(path = "/user/addresses", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
@Tag(name = "User Addresses", description = "Authenticated user address APIs")
public class AddressController {

    private final AddressService addressService;

    @Operation(
            summary = "Get current user addresses",
            description = "Returns all addresses that belong to the authenticated user."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Addresses returned",
                    content = @Content(schema = @Schema(implementation = AddressResponse.class))
            )
    })
    @GetMapping(version = "1.0")
    public ResponseEntity<List<AddressResponse>> getAddresses(
            @AuthenticationPrincipal ProductPortalUserPrincipal currentUser) {
        return ResponseEntity.ok(addressService.getAddressesForUser(currentUser.userId()));
    }

    @Operation(
            summary = "Create current user address",
            description = "Creates an address for the authenticated user. The request body must not include a user id."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "201",
                    description = "Address created",
                    content = @Content(schema = @Schema(implementation = AddressResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid address request",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Authenticated user no longer exists",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, version = "1.0")
    public ResponseEntity<AddressResponse> createAddress(
            @Valid @RequestBody AddressCreateRequest request,
            @AuthenticationPrincipal ProductPortalUserPrincipal currentUser) {
        AddressResponse response = addressService.createAddressForUser(request, currentUser.userId());
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{addressId}")
                .buildAndExpand(response.id())
                .toUri();

        return ResponseEntity.created(location).body(response);
    }

    @Operation(
            summary = "Get current user address by id",
            description = "Returns an address only when it belongs to the authenticated user."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Address found",
                    content = @Content(schema = @Schema(implementation = AddressResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid address id",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Address not found for the authenticated user",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @GetMapping(path = "/{addressId}", version = "1.0")
    public ResponseEntity<AddressResponse> getAddressById(
            @Parameter(description = "Positive address identifier", example = "1001", required = true)
            @PathVariable
            @Positive(message = "Address id must be positive")
            Long addressId,
            @AuthenticationPrincipal ProductPortalUserPrincipal currentUser) {
        return ResponseEntity.ok(addressService.getAddressByIdForUser(addressId, currentUser.userId()));
    }
}
