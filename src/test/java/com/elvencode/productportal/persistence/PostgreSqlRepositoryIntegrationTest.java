package com.elvencode.productportal.persistence;

import com.elvencode.productportal.auth.protection.entity.LoginThrottleScope;
import com.elvencode.productportal.auth.protection.repository.LoginThrottleStateRepository;
import com.elvencode.productportal.catalog.category.repository.CategoryRepository;
import com.elvencode.productportal.common.audit.AuditorAwareImpl;
import com.elvencode.productportal.common.config.FlywayMigrationConfig;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Import({FlywayMigrationConfig.class, AuditorAwareImpl.class})
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
}
