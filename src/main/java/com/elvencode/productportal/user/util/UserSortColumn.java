package com.elvencode.productportal.user.util;

import lombok.Getter;

/**
 * Enum defining sortable columns for User queries.
 * Prevents SQL injection by whitelisting allowed sort columns.
 * Enterprise-grade: centralized sort column management for all user endpoints.
 */
@Getter
public enum UserSortColumn {
    USERNAME("p.username", "username"),
    EMAIL("p.email", "email"),
    PHONE_NUMBER("p.phoneNumber", "phoneNumber"),
    FIRST_NAME("p.firstName", "firstName"),
    LAST_NAME("p.lastName", "lastName"),
    CREATED_AT("p.createdAt", "createdAt"),
    UPDATED_AT("p.updatedAt", "updatedAt"),
    STATUS("s.statusCode", "status");

    private final String jpqlField;
    private final String apiName;

    UserSortColumn(String jpqlField, String apiName) {
        this.jpqlField = jpqlField;
        this.apiName = apiName;
    }

    /**
     * Get enum by API name (case-insensitive).
     * Throws IllegalArgumentException if column not found.
     */
    public static UserSortColumn fromApiName(String apiName) {
        if (apiName == null || apiName.isBlank()) {
            return USERNAME; // Default sort column
        }
        for (UserSortColumn column : values()) {
            if (column.apiName.equalsIgnoreCase(apiName.trim())) {
                return column;
            }
        }
        throw new IllegalArgumentException("Invalid sort column: " + apiName + 
            ". Allowed columns: username, email, phoneNumber, firstName, lastName, createdAt, updatedAt, status");
    }
}
