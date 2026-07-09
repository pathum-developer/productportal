package com.elvencode.productportal.user.util;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

/**
 * Utility for validating and sanitizing sort parameters.
 * Prevents SQL injection by validating sort columns against allowed list.
 */
public class SortValidator {

    /**
     * Validate and sanitize Pageable sort parameters.
     * Replaces invalid sort columns with USERNAME (default).
     * 
     * @param pageable original pagination request
     * @return validated pageable with safe sort columns
     */
    public static Pageable validateAndSanitizeSort(Pageable pageable) {
        if (pageable == null || pageable.getSort().isEmpty()) {
            return PageRequest.of(
                pageable != null ? pageable.getPageNumber() : 0,
                pageable != null ? pageable.getPageSize() : 20,
                Sort.by(Sort.Direction.DESC, UserSortColumn.USERNAME.getApiName())
            );
        }

        Sort validatedSort = Sort.by(
            pageable.getSort().stream()
                .map(order -> {
                    try {
                        UserSortColumn column = UserSortColumn.fromApiName(order.getProperty());
                        return new Sort.Order(order.getDirection(), column.getApiName());
                    } catch (IllegalArgumentException e) {
                        // Invalid column — default to username
                        return new Sort.Order(Sort.Direction.DESC, UserSortColumn.USERNAME.getApiName());
                    }
                })
                .toArray(Sort.Order[]::new)
        );

        return PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), validatedSort);
    }
}
