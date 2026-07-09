package com.elvencode.productportal.user.address.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AddressCreateRequest(
        @NotBlank(message = "Recipient name is required")
        @Size(max = 150, message = "Recipient name must be at most 150 characters")
        String recipientName,

        @NotBlank(message = "Phone number is required")
        @Size(max = 30, message = "Phone number must be at most 30 characters")
        String phoneNumber,

        @NotBlank(message = "Address line 1 is required")
        @Size(max = 255, message = "Address line 1 must be at most 255 characters")
        String addressLine1,

        @Size(max = 255, message = "Address line 2 must be at most 255 characters")
        String addressLine2,

        @NotBlank(message = "City is required")
        @Size(max = 100, message = "City must be at most 100 characters")
        String city,

        @Size(max = 100, message = "District must be at most 100 characters")
        String district,

        @Size(max = 100, message = "Province must be at most 100 characters")
        String province,

        @Size(max = 20, message = "Postal code must be at most 20 characters")
        String postalCode,

        @NotBlank(message = "Country is required")
        @Size(max = 100, message = "Country must be at most 100 characters")
        String country,

        Boolean defaultAddress
) {
}
