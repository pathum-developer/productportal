package com.elvencode.productportal.catalog.category.service.impl;

import com.elvencode.productportal.catalog.category.repository.CategoryRepository;
import com.elvencode.productportal.catalog.category.service.CategoryHierarchyQueryService;
import com.elvencode.productportal.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryHierarchyQueryServiceImpl implements CategoryHierarchyQueryService {

    private final CategoryRepository categoryRepository;

    @Override
    public List<Long> getSelfAndDescendantCategoryIds(Long categoryId) {
        List<Long> categorySubtreeIds = categoryRepository.findSelfAndDescendantCategoryIds(categoryId);

        if (categorySubtreeIds.isEmpty()) {
            throw new ResourceNotFoundException("Category", "id", categoryId);
        }

        return categorySubtreeIds;
    }
}
