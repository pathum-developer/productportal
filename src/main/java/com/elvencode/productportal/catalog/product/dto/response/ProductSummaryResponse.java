package com.elvencode.productportal.catalog.product.dto.response;

import com.elvencode.productportal.catalog.brand.dto.response.BrandSummaryResponse;
import com.elvencode.productportal.catalog.category.dto.response.CategorySummaryResponse;
import com.elvencode.productportal.catalog.reference.dto.ReferenceStatusResponse;

public record ProductSummaryResponse(
        Long id,
        String name,
        String slug,
        String description,
        String modelNumber,
        String skuCode,
        CategorySummaryResponse category,
        BrandSummaryResponse brand,
        ReferenceStatusResponse status
) {
}
