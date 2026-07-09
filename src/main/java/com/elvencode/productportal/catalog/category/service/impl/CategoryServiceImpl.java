package com.elvencode.productportal.catalog.category.service.impl;

import com.elvencode.productportal.catalog.category.dto.response.CategoryDetailsResponse;
import com.elvencode.productportal.catalog.category.entity.Category;
import com.elvencode.productportal.catalog.category.mapper.CategoryMapper;
import com.elvencode.productportal.catalog.category.repository.CategoryRepository;
import com.elvencode.productportal.catalog.category.service.CategoryService;
import com.elvencode.productportal.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;

    @Override
    public CategoryDetailsResponse getCategoryDetailsById(Long categoryId) {
        Category category = categoryRepository.findWithParentCategoryAndStatusById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", categoryId));
        return categoryMapper.toDetailsResponse(category);
    }
}
