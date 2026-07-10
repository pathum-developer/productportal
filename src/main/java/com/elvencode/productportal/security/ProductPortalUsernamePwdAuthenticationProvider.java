package com.elvencode.productportal.security;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.assignment.repository.UserRoleAssignmentRepository;
import com.elvencode.productportal.access.permission.entity.RolePermissionGrant;
import com.elvencode.productportal.access.permission.repository.RolePermissionGrantRepository;
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

import java.time.Instant;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class ProductPortalUsernamePwdAuthenticationProvider implements AuthenticationProvider {

    private static final String ACTIVE_STATUS_CODE = "ACTIVE";
    private static final String ROLE_PREFIX = "ROLE_";

    private final UserRepository userRepository;
    private final UserRoleAssignmentRepository userRoleAssignmentRepository;
    private final RolePermissionGrantRepository rolePermissionGrantRepository;
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

        List<UserRoleAssignment> activeAssignments = loadActiveRoleAssignments(portalUser);
        List<String> roleCodes = extractRoleCodes(activeAssignments);
        List<String> permissionCodes = loadPermissionCodes(roleCodes);
        Long primaryOrganizationId = resolvePrimaryOrganizationId(portalUser, activeAssignments);

        ProductPortalUserPrincipal principal = new ProductPortalUserPrincipal(
                portalUser.getId(),
                portalUser.getUsername(),
                portalUser.getEmail(),
                portalUser.getPhoneNumber(),
                primaryOrganizationId,
                roleCodes,
                permissionCodes,
                portalUser.getStatus().getStatusCode());

        List<SimpleGrantedAuthority> authorities = buildAuthorities(roleCodes, permissionCodes);

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

    }

    private List<UserRoleAssignment> loadActiveRoleAssignments(PortalUser portalUser) {
        Instant now = Instant.now();
        List<UserRoleAssignment> activeAssignments = userRoleAssignmentRepository
                .findByUser_IdAndActiveTrue(portalUser.getId())
                .stream()
                .filter(assignment -> assignment.isCurrentlyActive(now))
                .sorted(Comparator
                        .comparing((UserRoleAssignment assignment) -> assignment.getRole().getSortOrder())
                        .thenComparing(assignment -> assignment.getRole().getRoleCode()))
                .toList();

        if (activeAssignments.isEmpty()) {
            throw new DisabledException("User has no active role assignments");
        }

        return activeAssignments;
    }

    private List<String> extractRoleCodes(List<UserRoleAssignment> activeAssignments) {
        return activeAssignments.stream()
                .map(assignment -> assignment.getRole().getRoleCode())
                .distinct()
                .toList();
    }

    private List<String> loadPermissionCodes(List<String> roleCodes) {
        return rolePermissionGrantRepository.findByRole_RoleCodeInAndActiveTrue(roleCodes)
                .stream()
                .filter(RolePermissionGrant::isCurrentlyActive)
                .sorted(Comparator
                        .comparing((RolePermissionGrant grant) -> grant.getPermission().getSortOrder())
                        .thenComparing(grant -> grant.getPermission().getPermissionCode()))
                .map(grant -> grant.getPermission().getPermissionCode())
                .distinct()
                .toList();
    }

    private Long resolvePrimaryOrganizationId(
            PortalUser portalUser,
            List<UserRoleAssignment> activeAssignments) {
        if (portalUser.getPrimaryOrganization() != null) {
            return portalUser.getPrimaryOrganization().getId();
        }
        return activeAssignments.get(0).getOrganization().getId();
    }

    private List<SimpleGrantedAuthority> buildAuthorities(List<String> roleCodes, List<String> permissionCodes) {
        Set<String> authorityNames = new LinkedHashSet<>();
        roleCodes.stream()
                .map(this::toRoleAuthority)
                .forEach(authorityNames::add);
        permissionCodes.stream()
                .map(this::toPermissionAuthority)
                .forEach(authorityNames::add);

        return authorityNames.stream()
                .map(SimpleGrantedAuthority::new)
                .toList();
    }

    private String toRoleAuthority(String roleCode) {
        return roleCode.startsWith(ROLE_PREFIX) ? roleCode : ROLE_PREFIX + roleCode;
    }

    private String toPermissionAuthority(String permissionCode) {
        return "PERMISSION_" + permissionCode;
    }
}
