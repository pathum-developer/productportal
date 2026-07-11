package com.elvencode.productportal.security;

import com.elvencode.productportal.auth.protection.dto.LoginRequestMetadata;
import com.elvencode.productportal.auth.protection.entity.LoginAttemptOutcome;
import com.elvencode.productportal.auth.protection.exception.LoginBlockedException;
import com.elvencode.productportal.auth.protection.service.LoginProtectionService;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.exception.CurrentUserAccessDeniedException;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.Nullable;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
@RequiredArgsConstructor
public class ProductPortalUsernamePwdAuthenticationProvider implements AuthenticationProvider {

    private static final String DUMMY_PASSWORD_HASH =
            "$2a$10$dXJ3SW6G7P50lGmMkk8WHe0b1BNkQonYgp7KYYb3RjW7TEkLHAeWO";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final LoginProtectionService loginProtectionService;
    private final CurrentUserAccessService currentUserAccessService;

    @Override
    public @Nullable Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String username = authentication.getName().trim().toLowerCase(Locale.ROOT);
        String password = authentication.getCredentials().toString();
        LoginRequestMetadata metadata = resolveMetadata(authentication);

        try {
            loginProtectionService.assertLoginAllowed(username, metadata);
        } catch (LoginBlockedException exception) {
            loginProtectionService.recordBlockedAttempt(username, exception, metadata);
            throw exception;
        }

        PortalUser portalUser = userRepository.findByUsername(username).orElse(null);
        if (portalUser == null) {
            passwordEncoder.matches(password, DUMMY_PASSWORD_HASH);
            loginProtectionService.recordBadCredentials(username, null, metadata);
            throw new BadCredentialsException("Invalid username or password");
        }

        if (!passwordEncoder.matches(password, portalUser.getPasswordHash())) {
            loginProtectionService.recordBadCredentials(username, portalUser.getId(), metadata);
            throw new BadCredentialsException("Invalid username or password");
        }

        ProductPortalAuthenticationContext authenticationContext = buildAuthenticationContext(
                username,
                portalUser,
                metadata);
        loginProtectionService.recordSuccessfulLogin(username, portalUser.getId(), metadata);

        return authenticationContext.toAuthentication();
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return (UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication));
    }

    private LoginRequestMetadata resolveMetadata(Authentication authentication) {
        Object details = authentication.getDetails();
        if (details instanceof LoginRequestMetadata metadata) {
            return metadata;
        }
        return LoginRequestMetadata.unknown();
    }

    private ProductPortalAuthenticationContext buildAuthenticationContext(
            String username,
            PortalUser portalUser,
            LoginRequestMetadata metadata) {
        try {
            return currentUserAccessService.buildContext(portalUser);
        } catch (CurrentUserAccessDeniedException exception) {
            loginProtectionService.recordSecurityFailure(
                    username,
                    portalUser.getId(),
                    toLoginAttemptOutcome(exception),
                    metadata);
            throw new DisabledException(exception.getMessage(), exception);
        }
    }

    private LoginAttemptOutcome toLoginAttemptOutcome(CurrentUserAccessDeniedException exception) {
        return switch (exception.reason()) {
            case ACCOUNT_DISABLED -> LoginAttemptOutcome.ACCOUNT_DISABLED;
            case NO_ACTIVE_ROLE_ASSIGNMENT -> LoginAttemptOutcome.NO_ACTIVE_ROLE_ASSIGNMENT;
            case USER_NOT_FOUND -> LoginAttemptOutcome.BAD_CREDENTIALS;
        };
    }
}
