package com.elvencode.productportal.security.authentication;

import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import java.util.List;

public record ProductPortalAuthenticationContext(
        ProductPortalUserPrincipal principal,
        List<GrantedAuthority> authorities
) {

    public ProductPortalAuthenticationContext {
        authorities = authorities == null ? List.of() : List.copyOf(authorities);
    }

    public Authentication toAuthentication() {
        return new UsernamePasswordAuthenticationToken(principal, null, authorities);
    }
}
