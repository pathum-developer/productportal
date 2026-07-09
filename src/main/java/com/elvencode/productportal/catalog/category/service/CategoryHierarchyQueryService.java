package com.elvencode.productportal.catalog.category.service;

import java.util.List;

public interface CategoryHierarchyQueryService {

    List<Long> getSelfAndDescendantCategoryIds(Long categoryId);
}
