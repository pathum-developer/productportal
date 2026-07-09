package com.elvencode.productportal.catalog.category.controller;

import com.elvencode.productportal.catalog.category.dto.response.CategoryDetailsResponse;
import com.elvencode.productportal.catalog.category.service.CategoryService;
import com.elvencode.productportal.common.dto.ErrorResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/categories", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
@Tag(name = "Categories", description = "Catalog category query APIs")
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(
            summary = "Get category details by id",
            description = "Returns category details including parent category, status, audit metadata, and version."
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Category found",
                    content = @Content(schema = @Schema(implementation = CategoryDetailsResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid category id",
                    content = @Content
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Category not found",
                    content = @Content(schema = @Schema(implementation = ErrorResponseDto.class))
            )
    })
    @GetMapping(path = "/{categoryId}", version = "1.0")
    public ResponseEntity<CategoryDetailsResponse> getCategoryDetailsById(
            @Parameter(description = "Positive category identifier", example = "1001", required = true)
            @PathVariable
            @Positive(message = "Category id must be positive")
            Long categoryId) {
        return ResponseEntity.ok(categoryService.getCategoryDetailsById(categoryId));
    }
}
