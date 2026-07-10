package com.elvencode.productportal.catalog.product.service.impl;

import com.elvencode.productportal.catalog.category.service.CategoryHierarchyQueryService;
import com.elvencode.productportal.catalog.product.dto.response.ProductSummaryResponse;
import com.elvencode.productportal.catalog.product.mapper.ProductMapper;
import com.elvencode.productportal.catalog.product.repository.ProductRepository;
import com.elvencode.productportal.catalog.product.service.ProductService;
import com.elvencode.productportal.catalog.shared.dto.PageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryProductQueryService implements ProductService {

    private final ProductRepository productRepository;
    private final CategoryHierarchyQueryService categoryHierarchyQueryService;
    private final ProductMapper productMapper;

    @Override
    public PageResponse<ProductSummaryResponse> getProductsByCategoryIdIncludingSubcategories(
            Long organizationId, Long categoryId, Pageable pageable) {
        List<Long> categorySubtreeIds = categoryHierarchyQueryService.getSelfAndDescendantCategoryIds(categoryId);

        return PageResponse.from(productRepository
                .findByOrganization_IdAndCategory_IdIn(organizationId, categorySubtreeIds, pageable)
                .map(productMapper::toSummaryResponse));
    }
}
