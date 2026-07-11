package com.elvencode.productportal.security.service.impl;

import com.elvencode.productportal.access.assignment.entity.UserRoleAssignment;
import com.elvencode.productportal.access.assignment.repository.UserRoleAssignmentRepository;
import com.elvencode.productportal.access.permission.entity.Permission;
import com.elvencode.productportal.access.permission.entity.RolePermissionGrant;
import com.elvencode.productportal.access.permission.repository.RolePermissionGrantRepository;
import com.elvencode.productportal.access.role.entity.Role;
import com.elvencode.productportal.organization.entity.Organization;
import com.elvencode.productportal.security.authentication.ProductPortalAuthenticationContext;
import com.elvencode.productportal.security.exception.CurrentUserAccessDeniedException;
import com.elvencode.productportal.user.entity.PortalUser;
import com.elvencode.productportal.user.reference.entity.UserStatus;
import com.elvencode.productportal.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.GrantedAuthority;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class CurrentUserAccessServiceImplTest {

    private static final Instant NOW = Instant.parse("2026-07-11T10:00:00Z");

    private UserRepository userRepository;
    private UserRoleAssignmentRepository userRoleAssignmentRepository;
    private RolePermissionGrantRepository rolePermissionGrantRepository;
    private CurrentUserAccessServiceImpl service;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        userRoleAssignmentRepository = mock(UserRoleAssignmentRepository.class);
        rolePermissionGrantRepository = mock(RolePermissionGrantRepository.class);
        service = new CurrentUserAccessServiceImpl(
                userRepository,
                userRoleAssignmentRepository,
                rolePermissionGrantRepository,
                Clock.fixed(NOW, ZoneOffset.UTC));
    }

    @Test
    void shouldBuildContextFromCurrentUserRolesAndPermissions() {
        PortalUser portalUser = activeUser();
        UserRoleAssignment assignment = activeAssignment("ADMIN", 1, 7L);
        RolePermissionGrant grant = activePermissionGrant("PRODUCT_READ", 1);

        when(userRepository.findById(42L)).thenReturn(Optional.of(portalUser));
        when(userRoleAssignmentRepository.findByUser_IdAndActiveTrue(42L))
                .thenReturn(List.of(assignment));
        when(rolePermissionGrantRepository.findByRole_RoleCodeInAndActiveTrue(List.of("ADMIN")))
                .thenReturn(List.of(grant));

        ProductPortalAuthenticationContext context = service.loadContextByUserId(42L);

        assertThat(context.principal().userId()).isEqualTo(42L);
        assertThat(context.principal().username()).isEqualTo("alice");
        assertThat(context.principal().primaryOrganizationId()).isEqualTo(7L);
        assertThat(context.principal().roleCodes()).containsExactly("ADMIN");
        assertThat(context.principal().permissionCodes()).containsExactly("PRODUCT_READ");
        assertThat(context.authorities())
                .extracting(GrantedAuthority::getAuthority)
                .containsExactly("ROLE_ADMIN", "PERMISSION_PRODUCT_READ");
        verify(userRepository).findById(42L);
    }

    @Test
    void shouldRejectDisabledCurrentUser() {
        PortalUser portalUser = activeUser();
        UserStatus status = portalUser.getStatus();
        when(status.getStatusCode()).thenReturn("INACTIVE");

        when(userRepository.findById(42L)).thenReturn(Optional.of(portalUser));

        assertThatThrownBy(() -> service.loadContextByUserId(42L))
                .isInstanceOf(CurrentUserAccessDeniedException.class)
                .satisfies(exception -> assertThat(((CurrentUserAccessDeniedException) exception).reason())
                        .isEqualTo(CurrentUserAccessDeniedException.Reason.ACCOUNT_DISABLED));
        verifyNoInteractions(userRoleAssignmentRepository, rolePermissionGrantRepository);
    }

    @Test
    void shouldRejectUserWithoutCurrentActiveRoleAssignments() {
        PortalUser portalUser = activeUser();

        when(userRepository.findById(42L)).thenReturn(Optional.of(portalUser));
        when(userRoleAssignmentRepository.findByUser_IdAndActiveTrue(42L)).thenReturn(List.of());

        assertThatThrownBy(() -> service.loadContextByUserId(42L))
                .isInstanceOf(CurrentUserAccessDeniedException.class)
                .satisfies(exception -> assertThat(((CurrentUserAccessDeniedException) exception).reason())
                        .isEqualTo(CurrentUserAccessDeniedException.Reason.NO_ACTIVE_ROLE_ASSIGNMENT));
        verifyNoInteractions(rolePermissionGrantRepository);
    }

    private PortalUser activeUser() {
        UserStatus status = mock(UserStatus.class);
        when(status.getStatusCode()).thenReturn("ACTIVE");
        when(status.getActive()).thenReturn(Boolean.TRUE);

        PortalUser portalUser = mock(PortalUser.class);
        when(portalUser.getId()).thenReturn(42L);
        when(portalUser.getUsername()).thenReturn("alice");
        when(portalUser.getEmail()).thenReturn("alice@example.test");
        when(portalUser.getPhoneNumber()).thenReturn("+94111111111");
        when(portalUser.getStatus()).thenReturn(status);
        when(portalUser.getPrimaryOrganization()).thenReturn(null);
        return portalUser;
    }

    private UserRoleAssignment activeAssignment(String roleCode, int sortOrder, Long organizationId) {
        Role role = mock(Role.class);
        when(role.getRoleCode()).thenReturn(roleCode);
        when(role.getSortOrder()).thenReturn(sortOrder);

        Organization organization = mock(Organization.class);
        when(organization.getId()).thenReturn(organizationId);

        UserRoleAssignment assignment = mock(UserRoleAssignment.class);
        when(assignment.isCurrentlyActive(any(Instant.class))).thenReturn(true);
        when(assignment.getRole()).thenReturn(role);
        when(assignment.getOrganization()).thenReturn(organization);
        return assignment;
    }

    private RolePermissionGrant activePermissionGrant(String permissionCode, int sortOrder) {
        Permission permission = mock(Permission.class);
        when(permission.getPermissionCode()).thenReturn(permissionCode);
        when(permission.getSortOrder()).thenReturn(sortOrder);

        RolePermissionGrant grant = mock(RolePermissionGrant.class);
        when(grant.isCurrentlyActive()).thenReturn(true);
        when(grant.getPermission()).thenReturn(permission);
        return grant;
    }
}
