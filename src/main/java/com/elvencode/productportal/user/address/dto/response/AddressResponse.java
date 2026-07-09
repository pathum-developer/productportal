package com.elvencode.productportal.user.address.dto.response;

import java.time.Instant;

public record AddressResponse(
        Long id,
        String recipientName,
        String phoneNumber,
        String addressLine1,
        String addressLine2,
        String city,
        String district,
        String province,
        String postalCode,
        String country,
        Boolean defaultAddress,
        Long version,
        Instant createdAt,
        String createdBy,
        Instant updatedAt,
        String updatedBy
) {
}
