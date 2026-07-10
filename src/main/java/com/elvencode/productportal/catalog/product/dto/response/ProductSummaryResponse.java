package com.elvencode.productportal.catalog.product.dto.response;

import com.elvencode.productportal.catalog.brand.dto.response.BrandSummaryResponse;
import com.elvencode.productportal.catalog.category.dto.response.CategorySummaryResponse;
import com.elvencode.productportal.catalog.reference.dto.ReferenceStatusResponse;
import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;
import com.elvencode.productportal.user.dto.response.UserSummaryResponse;

public record ProductSummaryResponse(
        Long id,
        String name,
        String slug,
        String description,
        String modelNumber,
        String skuCode,
        OrganizationSummaryResponse organization,
        UserSummaryResponse owner,
        CategorySummaryResponse category,
        BrandSummaryResponse brand,
        ReferenceStatusResponse status
) {
}
