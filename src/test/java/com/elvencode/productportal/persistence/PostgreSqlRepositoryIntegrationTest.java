package com.elvencode.productportal.persistence;

import com.elvencode.productportal.auth.protection.entity.LoginThrottleScope;
import com.elvencode.productportal.auth.protection.repository.LoginThrottleStateRepository;
import com.elvencode.productportal.catalog.category.repository.CategoryRepository;
import com.elvencode.productportal.catalog.product.repository.ProductRepository;
import com.elvencode.productportal.common.audit.AuditorAwareImpl;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DataJpaTest(properties = "spring.liquibase.contexts=reference,demo")
@Import(AuditorAwareImpl.class)
@Testcontainers
class PostgreSqlRepositoryIntegrationTest {

    @Container
    @ServiceConnection
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine")
            .withDatabaseName("productportal")
            .withUsername("productportal")
            .withPassword("productportal");

    @Autowired
    private LoginThrottleStateRepository loginThrottleStateRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void insertIfAbsentShouldCreateThrottleStateOnceWhenUniqueKeyConflicts() {
        String identifier = "integration-test-user@example.com";

        int firstInsertCount = loginThrottleStateRepository.insertIfAbsent(
                LoginThrottleScope.USERNAME.name(),
                identifier);
        int duplicateInsertCount = loginThrottleStateRepository.insertIfAbsent(
                LoginThrottleScope.USERNAME.name(),
                identifier);

        assertThat(firstInsertCount).isEqualTo(1);
        assertThat(duplicateInsertCount).isZero();
        assertThat(loginThrottleStateRepository.findByScopeAndIdentifier(
                LoginThrottleScope.USERNAME,
                identifier))
                .isPresent()
                .get()
                .satisfies(state -> {
                    assertThat(state.getScope()).isEqualTo(LoginThrottleScope.USERNAME);
                    assertThat(state.getIdentifier()).isEqualTo(identifier);
                    assertThat(state.getFailedAttemptCount()).isZero();
                });
    }

    @Test
    void findSelfAndDescendantCategoryIdsShouldReturnSeededCategorySubtree() {
        assertThat(categoryRepository.findSelfAndDescendantCategoryIds(1001L))
                .containsExactlyInAnyOrder(1001L, 1006L, 1007L, 1008L);
    }

    @Test
    void findSelfAndDescendantCategoryIdsShouldGuardAgainstInvalidHierarchyCycles() {
        jdbcTemplate.update("""
                UPDATE pp_m_category
                SET parent_category_id = ?
                WHERE category_id = ?
                """, 1006L, 1001L);

        assertThat(categoryRepository.findSelfAndDescendantCategoryIds(1001L))
                .doesNotHaveDuplicates()
                .containsExactlyInAnyOrder(1001L, 1006L, 1007L, 1008L);
    }

    @Test
    void productsShouldBeOwnedByOrganizationsWithoutUserOwnership() {
        Integer ownerColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_m_product'
                  AND column_name = 'owner_user_id'
                """, Integer.class);
        String organizationIdDefault = jdbcTemplate.queryForObject("""
                SELECT column_default
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_m_product'
                  AND column_name = 'organization_id'
                """, String.class);
        assertThat(ownerColumnCount).isZero();
        assertThat(organizationIdDefault).isNull();
        assertThat(productRepository.findByOrganization_IdAndCategory_IdIn(
                1L,
                List.of(1006L),
                PageRequest.of(0, 20)).getContent())
                .isNotEmpty()
                .allSatisfy(product -> assertThat(product.getOrganization().getId()).isEqualTo(1L));
    }

    @Test
    void usersShouldBelongToExactlyOneOrganizationWithRolesInsideThatOrganization() {
        Integer primaryOrganizationColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_m_user'
                  AND column_name = 'primary_organization_id'
                """, Integer.class);
        String organizationColumnNullable = jdbcTemplate.queryForObject("""
                SELECT is_nullable
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_m_user'
                  AND column_name = 'organization_id'
                """, String.class);
        Integer roleAssignmentOrganizationColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_t_user_role_assignment'
                  AND column_name = 'organization_id'
                """, Integer.class);
        Integer roleAssignmentAuditOrganizationColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_t_user_role_assignment_audit'
                  AND column_name = 'organization_id'
                """, Integer.class);
        Integer permissionScopeTableCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_r_permission_scope'
                """, Integer.class);
        Integer rolePermissionGrantScopeColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_t_role_permission_grant'
                  AND column_name = 'scope_code'
                """, Integer.class);
        Integer rolePermissionGrantAuditScopeColumnCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE table_schema = current_schema()
                  AND table_name = 'pp_t_role_permission_grant_audit'
                  AND column_name IN ('previous_scope_code', 'new_scope_code')
                """, Integer.class);
        Integer legacyMembershipTableCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = current_schema()
                  AND table_name IN (
                      'pp_t_user_organization_membership_audit',
                      'pp_t_user_organization_membership',
                      'pp_r_membership_status'
                  )
                """, Integer.class);

        jdbcTemplate.update("""
                INSERT INTO pp_m_organization
                    (organization_id, organization_code, display_name, is_active, created_by)
                VALUES
                    (9002, 'TEST-ORG-9002', 'Test Organization 9002', TRUE, 'TEST')
                """);

        assertThat(primaryOrganizationColumnCount).isZero();
        assertThat(organizationColumnNullable).isEqualTo("NO");
        assertThat(roleAssignmentOrganizationColumnCount).isZero();
        assertThat(roleAssignmentAuditOrganizationColumnCount).isZero();
        assertThat(permissionScopeTableCount).isZero();
        assertThat(rolePermissionGrantScopeColumnCount).isZero();
        assertThat(rolePermissionGrantAuditScopeColumnCount).isZero();
        assertThat(legacyMembershipTableCount).isZero();

        jdbcTemplate.update("""
                INSERT INTO pp_t_user_role_assignment
                    (user_id, role_code, is_active, assigned_by, assigned_reason)
                VALUES
                    (5002, 'SELLER', TRUE, 'TEST', 'Integration audit check')
                """);

        Integer roleAssignmentAuditCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM pp_t_user_role_assignment_audit
                WHERE user_id = 5002
                  AND role_code = 'SELLER'
                  AND event_type = 'ASSIGNED'
                """, Integer.class);

        jdbcTemplate.update("""
                INSERT INTO pp_t_role_permission_grant
                    (role_code, permission_code, is_active, assigned_by, assigned_reason)
                VALUES
                    ('BUYER', 'PRODUCT_DELETE', TRUE, 'TEST', 'Integration audit check')
                """);

        Integer rolePermissionGrantAuditCount = jdbcTemplate.queryForObject("""
                SELECT COUNT(*)
                FROM pp_t_role_permission_grant_audit
                WHERE role_code = 'BUYER'
                  AND permission_code = 'PRODUCT_DELETE'
                  AND event_type = 'ASSIGNED'
                """, Integer.class);

        assertThat(roleAssignmentAuditCount).isEqualTo(1);
        assertThat(rolePermissionGrantAuditCount).isEqualTo(1);
        assertThatThrownBy(() -> jdbcTemplate.update("""
                INSERT INTO pp_t_user_role_assignment
                    (user_id, role_code, is_active, assigned_by)
                VALUES
                    (5001, 'BUYER', TRUE, 'TEST')
                """))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
