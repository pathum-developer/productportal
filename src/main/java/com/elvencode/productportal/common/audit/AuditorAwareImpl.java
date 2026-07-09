package com.elvencode.productportal.common.audit;

import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Optional;

@Component("auditorAwareImpl")
public class AuditorAwareImpl implements AuditorAware<String> {

    private static final String SYSTEM_AUDITOR = "SYSTEM";

    @Override
    public Optional<String> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return Optional.of(SYSTEM_AUDITOR);
        }

        return resolveAuditor(authentication.getPrincipal())
                .filter(StringUtils::hasText)
                .map(String::trim)
                .or(() -> Optional.of(SYSTEM_AUDITOR));
    }

    private Optional<String> resolveAuditor(Object principal) {
        if (principal instanceof ProductPortalUserPrincipal productPortalUserPrincipal) {
            return Optional.ofNullable(productPortalUserPrincipal.username());
        }

        if (principal instanceof UserDetails userDetails) {
            return Optional.ofNullable(userDetails.getUsername());
        }

        if (principal instanceof String username) {
            return Optional.of(username);
        }

        return Optional.empty();
    }
}
