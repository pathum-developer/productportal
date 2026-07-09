package com.elvencode.productportal.security;

import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
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
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Locale;

@Component
@RequiredArgsConstructor
public class ProductPortalUsernamePwdAuthenticationProvider implements AuthenticationProvider {

    private static final String ACTIVE_STATUS_CODE = "ACTIVE";
    private static final String ROLE_PREFIX = "ROLE_";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public @Nullable Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String username = authentication.getName().trim().toLowerCase(Locale.ROOT);
        String password = authentication.getCredentials().toString();

        PortalUser portalUser = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException(
                        "User details not found for the user: " + username)
                );

        validateAccountCanAuthenticate(portalUser);

        if (!passwordEncoder.matches(password, portalUser.getPasswordHash())) {
            throw new BadCredentialsException("Invalid password!");
        }

        ProductPortalUserPrincipal principal = new ProductPortalUserPrincipal(
                portalUser.getId(),
                portalUser.getUsername(),
                portalUser.getEmail(),
                portalUser.getPhoneNumber(),
                portalUser.getRole().getRoleCode(),
                portalUser.getStatus().getStatusCode());

        List<SimpleGrantedAuthority> authorities = List.of(
                new SimpleGrantedAuthority(toRoleAuthority(portalUser.getRole().getRoleCode())));

        return new UsernamePasswordAuthenticationToken(principal, null, authorities);
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return (UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication));
    }

    private void validateAccountCanAuthenticate(PortalUser portalUser) {
        if (!ACTIVE_STATUS_CODE.equals(portalUser.getStatus().getStatusCode())
                || !Boolean.TRUE.equals(portalUser.getStatus().getActive())) {
            throw new DisabledException("User account is not active");
        }

        if (!Boolean.TRUE.equals(portalUser.getRole().getActive())) {
            throw new DisabledException("User role is not active");
        }
    }

    private String toRoleAuthority(String roleCode) {
        return roleCode.startsWith(ROLE_PREFIX) ? roleCode : ROLE_PREFIX + roleCode;
    }
}
