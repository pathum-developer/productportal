package com.elvencode.productportal.catalog.product.mapper;

import com.elvencode.productportal.catalog.brand.dto.response.BrandSummaryResponse;
import com.elvencode.productportal.catalog.brand.entity.Brand;
import com.elvencode.productportal.catalog.category.dto.response.CategorySummaryResponse;
import com.elvencode.productportal.catalog.category.entity.Category;
import com.elvencode.productportal.catalog.product.dto.response.ProductSummaryResponse;
import com.elvencode.productportal.catalog.product.entity.Product;
import com.elvencode.productportal.catalog.reference.dto.ReferenceStatusResponse;
import com.elvencode.productportal.catalog.reference.entity.ProductStatus;
import com.elvencode.productportal.organization.dto.response.OrganizationSummaryResponse;
import com.elvencode.productportal.organization.entity.Organization;
import org.springframework.stereotype.Component;

@Component
public class ProductMapper {

    public ProductSummaryResponse toSummaryResponse(Product product) {
        return new ProductSummaryResponse(
                product.getId(),
                product.getName(),
                product.getSlug(),
                product.getDescription(),
                product.getModelNumber(),
                product.getSkuCode(),
                toOrganizationSummary(product.getOrganization()),
                toCategorySummary(product.getCategory()),
                toBrandSummary(product.getBrand()),
                toStatusResponse(product.getStatus()));
    }

    private CategorySummaryResponse toCategorySummary(Category category) {
        return new CategorySummaryResponse(
                category.getId(),
                category.getName(),
                category.getSlug());
    }

    private BrandSummaryResponse toBrandSummary(Brand brand) {
        if (brand == null) {
            return null;
        }
        return new BrandSummaryResponse(
                brand.getId(),
                brand.getName(),
                brand.getSlug(),
                brand.getLogoUrl());
    }

    private OrganizationSummaryResponse toOrganizationSummary(Organization organization) {
        return new OrganizationSummaryResponse(
                organization.getId(),
                organization.getOrganizationCode(),
                organization.getDisplayName(),
                organization.getActive());
    }

    private ReferenceStatusResponse toStatusResponse(ProductStatus status) {
        return new ReferenceStatusResponse(
                status.getStatusCode(),
                status.getDisplayName(),
                status.getActive());
    }
}
