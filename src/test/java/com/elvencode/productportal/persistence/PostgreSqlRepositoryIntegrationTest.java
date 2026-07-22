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
import org.springframework.data.domain.PageRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

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
        String sellerProductUpdateScope = jdbcTemplate.queryForObject("""
                SELECT scope_code
                FROM pp_t_role_permission_grant
                WHERE role_code = 'SELLER'
                  AND permission_code = 'PRODUCT_UPDATE'
                """, String.class);

        assertThat(ownerColumnCount).isZero();
        assertThat(organizationIdDefault).isNull();
        assertThat(sellerProductUpdateScope).isEqualTo("ORGANIZATION");
        assertThat(productRepository.findByOrganization_IdAndCategory_IdIn(
                1L,
                List.of(1006L),
                PageRequest.of(0, 20)).getContent())
                .isNotEmpty()
                .allSatisfy(product -> assertThat(product.getOrganization().getId()).isEqualTo(1L));
    }
}
