package com.elvencode.productportal.catalog.category.mapper;

import com.elvencode.productportal.catalog.category.dto.response.CategoryDetailsResponse;
import com.elvencode.productportal.catalog.category.dto.response.CategorySummaryResponse;
import com.elvencode.productportal.catalog.category.entity.Category;
import com.elvencode.productportal.catalog.reference.dto.ReferenceStatusResponse;
import com.elvencode.productportal.catalog.reference.entity.CategoryStatus;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {

    public CategoryDetailsResponse toDetailsResponse(Category category) {
        return new CategoryDetailsResponse(
                category.getId(),
                category.getName(),
                category.getSlug(),
                toSummaryResponse(category.getParentCategory()),
                toStatusResponse(category.getStatus()),
                category.getSortOrder(),
                category.getVersion(),
                category.getCreatedAt(),
                category.getCreatedBy(),
                category.getUpdatedAt(),
                category.getUpdatedBy());
    }

    private CategorySummaryResponse toSummaryResponse(Category category) {
        if (category == null) {
            return null;
        }
        return new CategorySummaryResponse(
                category.getId(),
                category.getName(),
                category.getSlug());
    }

    private ReferenceStatusResponse toStatusResponse(CategoryStatus status) {
        return new ReferenceStatusResponse(
                status.getStatusCode(),
                status.getDisplayName(),
                status.getActive());
    }
}
