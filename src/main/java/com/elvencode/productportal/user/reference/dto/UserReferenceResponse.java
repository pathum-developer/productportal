package com.elvencode.productportal.user.reference.dto;

public record UserReferenceResponse(
        String code,
        String displayName,
        Boolean active
) {
}
