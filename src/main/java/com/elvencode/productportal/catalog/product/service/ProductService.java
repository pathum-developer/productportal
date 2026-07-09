package com.elvencode.productportal.catalog.product.service;

import com.elvencode.productportal.catalog.product.dto.response.ProductSummaryResponse;
import com.elvencode.productportal.catalog.shared.dto.PageResponse;
import jakarta.validation.constraints.Positive;
import org.springframework.data.domain.Pageable;

public interface ProductService {

    PageResponse<ProductSummaryResponse> getProductsByCategoryIdIncludingSubcategories(
            Long categoryId, Pageable pageable);

}
