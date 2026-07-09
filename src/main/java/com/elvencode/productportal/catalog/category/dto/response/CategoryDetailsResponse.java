package com.elvencode.productportal.catalog.category.dto.response;

import com.elvencode.productportal.catalog.reference.dto.ReferenceStatusResponse;

import java.time.Instant;

public record CategoryDetailsResponse(
        Long id,
        String name,
        String slug,
        CategorySummaryResponse parentCategory,
        ReferenceStatusResponse status,
        Integer sortOrder,
        Long version,
        Instant createdAt,
        String createdBy,
        Instant updatedAt,
        String updatedBy
) {
}
