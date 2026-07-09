package com.elvencode.productportal.catalog.category.service;

import com.elvencode.productportal.catalog.category.dto.response.CategoryDetailsResponse;

public interface CategoryService {

    CategoryDetailsResponse getCategoryDetailsById(Long categoryId);
}
