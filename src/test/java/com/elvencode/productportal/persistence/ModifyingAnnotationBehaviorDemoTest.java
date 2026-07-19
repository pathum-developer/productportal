package com.elvencode.productportal.persistence;

import com.elvencode.productportal.common.audit.AuditorAwareImpl;
import com.elvencode.productportal.user.address.entity.Address;
import com.elvencode.productportal.user.entity.PortalUser;
import jakarta.persistence.EntityManager;
import org.hibernate.FlushMode;
import org.hibernate.Session;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.support.JpaRepositoryFactory;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Manual-only learning aid.
 *
 * <p>This class is intentionally not registered as a JUnit/Spring test. To run it manually,
 * uncomment the MANUAL-RUN annotations below and run:</p>
 *
 * <p>{@code .\mvnw.cmd "-Dtest=ModifyingAnnotationBehaviorDemoTest" "-Dsurefire.useFile=false" test}</p>
 *
 * <p>The test deliberately uses Hibernate {@link FlushMode#MANUAL} so an implicit flush does not
 * hide the observable difference between the {@link Modifying} configurations.</p>
 */
// MANUAL-RUN:
//@DataJpaTest(showSql = false, properties = {
//        "spring.liquibase.contexts=reference,demo",
//        "spring.jpa.show-sql=false",
//        "logging.level.org.hibernate.SQL=OFF",
//        "logging.level.org.hibernate.orm.jdbc.bind=OFF"
//})
//@Import({AuditorAwareImpl.class, ModifyingAnnotationBehaviorDemoTest.DemoRepositoryConfiguration.class})
//@Testcontainers
//@Tag("learning-demo")
class ModifyingAnnotationBehaviorDemoTest {

    private static final long DEMO_USER_ID = 5001L;
    private static final String ORIGINAL_CITY = "Original City";
    private static final String PENDING_CITY = "Pending City";

    // MANUAL-RUN:
//    @Container
//    @ServiceConnection
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine")
            .withDatabaseName("productportal")
            .withUsername("productportal")
            .withPassword("productportal");

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private DemoAddressRepository demoAddressRepository;

    // MANUAL-RUN:
//    @Test
    void demonstrateModifyingFlushAndClearOptionsUsingAnAddress() {
        System.out.println("[START] demonstrateModifyingFlushAndClearOptionsUsingAnAddress");
        Session hibernateSession = null;
        FlushMode originalFlushMode = null;

        try {
            hibernateSession = entityManager.unwrap(Session.class);
            originalFlushMode = hibernateSession.getHibernateFlushMode();
            hibernateSession.setHibernateFlushMode(FlushMode.MANUAL);

            printIntroduction();

            demonstrateScenario(
                    "1. @Modifying only",
                    demoAddressRepository::clearDefaultAddressOnlyModifying,
                    true,
                    new DatabaseAddressState(ORIGINAL_CITY, false),
                    new DatabaseAddressState(PENDING_CITY, true));

//            demonstrateScenario(
//                    "2. @Modifying(flushAutomatically = true)",
//                    demoAddressRepository::clearDefaultAddressWithAutomaticFlush,
//                    true,
//                    new DatabaseAddressState(PENDING_CITY, false),
//                    new DatabaseAddressState(PENDING_CITY, false));
//
//            demonstrateScenario(
//                    "3. @Modifying(clearAutomatically = true)",
//                    demoAddressRepository::clearDefaultAddressWithAutomaticClear,
//                    false,
//                    new DatabaseAddressState(ORIGINAL_CITY, false),
//                    new DatabaseAddressState(ORIGINAL_CITY, false));
//
//            demonstrateScenario(
//                    "4. @Modifying(flushAutomatically = true, clearAutomatically = true)",
//                    demoAddressRepository::clearDefaultAddressWithAutomaticFlushAndClear,
//                    false,
//                    new DatabaseAddressState(PENDING_CITY, false),
//                    new DatabaseAddressState(PENDING_CITY, false));
        } finally {
            if (hibernateSession != null && originalFlushMode != null) {
                hibernateSession.setHibernateFlushMode(originalFlushMode);
            }
            System.out.println("[END] demonstrateModifyingFlushAndClearOptionsUsingAnAddress");
        }
    }

    private void demonstrateScenario(
            String scenarioName,
            DefaultAddressBulkUpdater bulkUpdater,
            boolean expectedManagedAfterBulkUpdate,
            DatabaseAddressState expectedDatabaseStateAfterBulkUpdate,
            DatabaseAddressState expectedDatabaseStateAfterExplicitFlush) {
        System.out.printf("[START] demonstrateScenario: %s%n", scenarioName);

        try {
            Long addressId = persistDefaultAddress();
            Address managedAddress = entityManager.find(Address.class, addressId);

            managedAddress.setCity(PENDING_CITY);

            System.out.printf("%n========== %s ==========%n", scenarioName);
            printState("Before the bulk update", addressId, managedAddress);

            System.out.printf("[START] DefaultAddressBulkUpdater.clearDefaultAddress: %s%n", scenarioName);
            int affectedRows;
            try {
                affectedRows = bulkUpdater.clearDefaultAddress(addressId);
            } finally {
                System.out.printf("[END] DefaultAddressBulkUpdater.clearDefaultAddress: %s%n", scenarioName);
            }
            DatabaseAddressState stateAfterBulkUpdate = loadDatabaseState(addressId);

            System.out.printf("Rows updated by JPQL bulk UPDATE: %d%n", affectedRows);
            printState("Immediately after the bulk update", addressId, managedAddress);

            assertThat(affectedRows).isOne();
            assertThat(entityManager.contains(managedAddress)).isEqualTo(expectedManagedAfterBulkUpdate);
            assertThat(stateAfterBulkUpdate).isEqualTo(expectedDatabaseStateAfterBulkUpdate);

            entityManager.flush();
            entityManager.clear();

            DatabaseAddressState stateAfterExplicitFlush = loadDatabaseState(addressId);
            System.out.println("After an explicit flush and clear:");
            printDatabaseState(stateAfterExplicitFlush);

            assertThat(stateAfterExplicitFlush).isEqualTo(expectedDatabaseStateAfterExplicitFlush);
        } finally {
            System.out.printf("[END] demonstrateScenario: %s%n", scenarioName);
        }
    }

    private Long persistDefaultAddress() {
        System.out.println("[START] persistDefaultAddress");
        try {
            PortalUser userReference = entityManager.getReference(PortalUser.class, DEMO_USER_ID);
            Address address = Address.create(
                    userReference,
                    "Learning Demo Recipient",
                    "+94770000000",
                    "1 Learning Street",
                    null,
                    ORIGINAL_CITY,
                    null,
                    null,
                    null,
                    "Sri Lanka",
                    true);

            entityManager.persist(address);
            entityManager.flush();
            entityManager.clear();
            return address.getId();
        } finally {
            System.out.println("[END] persistDefaultAddress");
        }
    }

    private void printIntroduction() {
        System.out.println("[START] printIntroduction");
        try {
            System.out.println("""

                ==============================================================================
                SIMPLE DEMO: @Modifying flushAutomatically / clearAutomatically
                Java changes city from "Original City" to "Pending City" without saving it.
                The JPQL bulk UPDATE changes defaultAddress from true to false in PostgreSQL.
                Hibernate FlushMode.MANUAL is intentionally used so the annotation behavior is visible.
                ==============================================================================
                    """);
        } finally {
            System.out.println("[END] printIntroduction");
        }
    }

    private void printState(String stage, Long addressId, Address address) {
        System.out.printf("[START] printState: %s%n", stage);
        try {
            System.out.println(stage + ":");
            System.out.printf(
                    "  Hibernate managed: %s%n  Java address:      city=%s, defaultAddress=%s%n",
                    entityManager.contains(address),
                    address.getCity(),
                    address.getDefaultAddress());
            printDatabaseState(loadDatabaseState(addressId));
        } finally {
            System.out.printf("[END] printState: %s%n", stage);
        }
    }

    private void printDatabaseState(DatabaseAddressState state) {
        System.out.println("[START] printDatabaseState");
        try {
            System.out.printf(
                    "  PostgreSQL row:   city=%s, defaultAddress=%s%n",
                    state.city(),
                    state.defaultAddress());
        } finally {
            System.out.println("[END] printDatabaseState");
        }
    }

    private DatabaseAddressState loadDatabaseState(Long addressId) {
        System.out.printf("[START] loadDatabaseState: addressId=%d%n", addressId);
        try {
            return jdbcTemplate.queryForObject(
                    """
                            SELECT city, is_default
                            FROM pp_m_user_address
                            WHERE address_id = ?
                            """,
                    (resultSet, rowNumber) -> new DatabaseAddressState(
                            resultSet.getString("city"),
                            resultSet.getBoolean("is_default")),
                    addressId);
        } finally {
            System.out.printf("[END] loadDatabaseState: addressId=%d%n", addressId);
        }
    }

    @FunctionalInterface
    private interface DefaultAddressBulkUpdater {

        int clearDefaultAddress(Long addressId);
    }

    private record DatabaseAddressState(String city, boolean defaultAddress) {
    }

    interface DemoAddressRepository extends Repository<Address, Long> {

        @Modifying
        @Query("UPDATE Address address SET address.defaultAddress = false WHERE address.id = :addressId")
        int clearDefaultAddressOnlyModifying(@Param("addressId") Long addressId);

        @Modifying(flushAutomatically = true)
        @Query("UPDATE Address address SET address.defaultAddress = false WHERE address.id = :addressId")
        int clearDefaultAddressWithAutomaticFlush(@Param("addressId") Long addressId);

        @Modifying(clearAutomatically = true)
        @Query("UPDATE Address address SET address.defaultAddress = false WHERE address.id = :addressId")
        int clearDefaultAddressWithAutomaticClear(@Param("addressId") Long addressId);

        @Modifying(flushAutomatically = true, clearAutomatically = true)
        @Query("UPDATE Address address SET address.defaultAddress = false WHERE address.id = :addressId")
        int clearDefaultAddressWithAutomaticFlushAndClear(@Param("addressId") Long addressId);
    }

    // MANUAL-RUN:
//    @TestConfiguration(proxyBeanMethods = false)
    static class DemoRepositoryConfiguration {

        // MANUAL-RUN:
//        @Bean
        DemoAddressRepository demoAddressRepository(EntityManager entityManager) {
            System.out.println("[START] DemoRepositoryConfiguration.demoAddressRepository");
            try {
                return new JpaRepositoryFactory(entityManager).getRepository(DemoAddressRepository.class);
            } finally {
                System.out.println("[END] DemoRepositoryConfiguration.demoAddressRepository");
            }
        }
    }
}
