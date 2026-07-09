package com.elvencode.productportal.catalog.brand.dto.response;

public record BrandSummaryResponse(
        Long id,
        String name,
        String slug,
        String logoUrl
) {
}
