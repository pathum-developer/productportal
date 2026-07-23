package com.elvencode.productportal.catalog.product.controller;

import com.elvencode.productportal.catalog.product.dto.response.ProductSummaryResponse;
import com.elvencode.productportal.catalog.product.service.ProductService;
import com.elvencode.productportal.catalog.shared.dto.PageResponse;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/products",produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
public class CategoryProductController {

    private final ProductService productService;

    @GetMapping(path = "/categories/{categoryId}", version = "1.0")
    public ResponseEntity<PageResponse<ProductSummaryResponse>> getProductsByCategoryIdIncludingSubcategories(
            @PathVariable @Positive(message = "Category id must be positive") Long categoryId,
            @AuthenticationPrincipal ProductPortalUserPrincipal currentUser,
            @PageableDefault(size = 20, sort = "name") Pageable pageable) {
        return ResponseEntity.ok(productService.getProductsByCategoryIdIncludingSubcategories(
                currentUser.organizationId(), categoryId, pageable));
    }

}
