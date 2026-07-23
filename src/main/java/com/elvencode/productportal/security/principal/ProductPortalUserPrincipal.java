package com.elvencode.productportal.security.principal;

import java.security.Principal;
import java.util.List;

public record ProductPortalUserPrincipal(
        Long userId,
        String username,
        String email,
        String phoneNumber,
        Long organizationId,
        List<String> roleCodes,
        List<String> permissionCodes,
        String statusCode
) implements Principal {

    public ProductPortalUserPrincipal {
        roleCodes = roleCodes == null ? List.of() : List.copyOf(roleCodes);
        permissionCodes = permissionCodes == null ? List.of() : List.copyOf(permissionCodes);
    }

    @Override
    public String getName() {
        return username;
    }
}
