package com.elvencode.productportal.security.principal;

import java.security.Principal;

public record ProductPortalUserPrincipal(
        Long userId,
        String username,
        String email,
        String phoneNumber,
        String roleCode,
        String statusCode
) implements Principal {

    @Override
    public String getName() {
        return username;
    }
}
