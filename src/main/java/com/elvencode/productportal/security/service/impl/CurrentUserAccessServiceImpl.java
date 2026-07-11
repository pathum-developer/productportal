package com.elvencode.productportal.security.service.impl;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.assignment.repository.UserRoleAssignmentRepository;
import com.elvencode.productportal.access.permission.entity.RolePermissionGrant;
import com.elvencode.productportal.access.permission.repository.RolePermissionGrantRepository;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.exception.CurrentUserAccessDeniedException;
import com.elvencode.productportal.security.principal.ProductPortalUserPrincipal;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class CurrentUserAccessServiceImpl implements CurrentUserAccessService {

    private static final String ACTIVE_STATUS_CODE = "ACTIVE";
    private static final String ROLE_PREFIX = "ROLE_";

    private final UserRepository userRepository;
    private final UserRoleAssignmentRepository userRoleAssignmentRepository;
    private final RolePermissionGrantRepository rolePermissionGrantRepository;
    private final Clock clock;

    @Transactional(readOnly = true)
    @Override
    public ProductPortalAuthenticationContext loadContextByUserId(Long userId) {
        PortalUser portalUser = userRepository.findById(userId)
                .orElseThrow(() -> new CurrentUserAccessDeniedException(
                        CurrentUserAccessDeniedException.Reason.USER_NOT_FOUND));

        return buildContext(portalUser);
    }

    @Transactional(readOnly = true)
    @Override
    public ProductPortalAuthenticationContext buildContext(PortalUser portalUser) {
        if (!canAccountAuthenticate(portalUser)) {
            throw new CurrentUserAccessDeniedException(
                    CurrentUserAccessDeniedException.Reason.ACCOUNT_DISABLED);
        }

        List<UserRoleAssignment> activeAssignments = loadActiveRoleAssignments(portalUser);
        if (activeAssignments.isEmpty()) {
            throw new CurrentUserAccessDeniedException(
                    CurrentUserAccessDeniedException.Reason.NO_ACTIVE_ROLE_ASSIGNMENT);
        }

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

        return new ProductPortalAuthenticationContext(
                principal,
                buildAuthorities(roleCodes, permissionCodes));
    }

    private boolean canAccountAuthenticate(PortalUser portalUser) {
        return ACTIVE_STATUS_CODE.equals(portalUser.getStatus().getStatusCode())
                && Boolean.TRUE.equals(portalUser.getStatus().getActive());
    }

    private List<UserRoleAssignment> loadActiveRoleAssignments(PortalUser portalUser) {
        Instant now = clock.instant();
        return userRoleAssignmentRepository
                .findByUser_IdAndActiveTrue(portalUser.getId())
                .stream()
                .filter(assignment -> assignment.isCurrentlyActive(now))
                .sorted(Comparator
                        .comparing((UserRoleAssignment assignment) -> assignment.getRole().getSortOrder())
                        .thenComparing(assignment -> assignment.getRole().getRoleCode()))
                .toList();
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

    private List<GrantedAuthority> buildAuthorities(List<String> roleCodes, List<String> permissionCodes) {
        Set<String> authorityNames = new LinkedHashSet<>();
        roleCodes.stream()
                .map(this::toRoleAuthority)
                .forEach(authorityNames::add);
        permissionCodes.stream()
                .map(this::toPermissionAuthority)
                .forEach(authorityNames::add);

        return authorityNames.stream()
                .map(SimpleGrantedAuthority::new)
                .map(GrantedAuthority.class::cast)
                .toList();
    }

    private String toRoleAuthority(String roleCode) {
        return roleCode.startsWith(ROLE_PREFIX) ? roleCode : ROLE_PREFIX + roleCode;
    }

    private String toPermissionAuthority(String permissionCode) {
        return "PERMISSION_" + permissionCode;
    }
}
