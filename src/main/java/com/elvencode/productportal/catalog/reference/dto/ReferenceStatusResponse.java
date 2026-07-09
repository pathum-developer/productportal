package com.elvencode.productportal.catalog.reference.dto;

public record ReferenceStatusResponse(
        String code,
        String displayName,
        Boolean active
) {
}
