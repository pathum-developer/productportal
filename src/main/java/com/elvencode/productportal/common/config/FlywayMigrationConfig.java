package com.elvencode.productportal.common.config;

import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.output.MigrateResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.util.Arrays;

@Configuration(proxyBeanMethods = false)
public class FlywayMigrationConfig {

    private static final String ENTITY_MANAGER_FACTORY_BEAN_NAME = "entityManagerFactory";
    private static final String FLYWAY_INITIALIZER_BEAN_NAME = "productPortalFlywayMigrationInitializer";

    @Bean
    ProductPortalFlywayMigrationInitializer productPortalFlywayMigrationInitializer(
            DataSource dataSource,
            Environment environment) {
        return new ProductPortalFlywayMigrationInitializer(dataSource, environment);
    }

    @Bean
    static BeanFactoryPostProcessor entityManagerFactoryDependsOnFlywayMigration() {
        return FlywayMigrationConfig::makeEntityManagerFactoryDependOnFlyway;
    }

    private static void makeEntityManagerFactoryDependOnFlyway(ConfigurableListableBeanFactory beanFactory) {
        if (!beanFactory.containsBeanDefinition(ENTITY_MANAGER_FACTORY_BEAN_NAME)) {
            return;
        }

        BeanDefinition entityManagerFactory = beanFactory.getBeanDefinition(ENTITY_MANAGER_FACTORY_BEAN_NAME);
        String[] existingDependencies = entityManagerFactory.getDependsOn();

        if (existingDependencies != null
                && Arrays.asList(existingDependencies).contains(FLYWAY_INITIALIZER_BEAN_NAME)) {
            return;
        }

        String[] updatedDependencies = appendDependency(existingDependencies);
        entityManagerFactory.setDependsOn(updatedDependencies);
    }

    private static String[] appendDependency(String[] existingDependencies) {
        if (existingDependencies == null || existingDependencies.length == 0) {
            return new String[]{FLYWAY_INITIALIZER_BEAN_NAME};
        }

        String[] updatedDependencies = Arrays.copyOf(existingDependencies, existingDependencies.length + 1);
        updatedDependencies[existingDependencies.length] = FLYWAY_INITIALIZER_BEAN_NAME;
        return updatedDependencies;
    }

    static final class ProductPortalFlywayMigrationInitializer implements InitializingBean {

        private static final Logger log = LoggerFactory.getLogger(ProductPortalFlywayMigrationInitializer.class);
        private static final String DEFAULT_LOCATION = "classpath:db/migration";

        private final DataSource dataSource;
        private final Environment environment;

        private ProductPortalFlywayMigrationInitializer(DataSource dataSource, Environment environment) {
            this.dataSource = dataSource;
            this.environment = environment;
        }

        @Override
        public void afterPropertiesSet() {
            if (!environment.getProperty("spring.flyway.enabled", Boolean.class, Boolean.TRUE)) {
                log.info("Flyway migration is disabled by spring.flyway.enabled=false.");
                return;
            }

            String[] locations = resolveMigrationLocations();
            MigrateResult result = Flyway.configure()
                    .dataSource(dataSource)
                    .locations(locations)
                    .load()
                    .migrate();

            log.info(
                    "Flyway migration completed. migrationsExecuted={}, targetSchemaVersion={}",
                    result.migrationsExecuted,
                    result.targetSchemaVersion);
        }

        private String[] resolveMigrationLocations() {
            String configuredLocations = environment.getProperty("spring.flyway.locations", DEFAULT_LOCATION);

            String[] locations = Arrays.stream(StringUtils.commaDelimitedListToStringArray(configuredLocations))
                    .map(String::trim)
                    .filter(StringUtils::hasText)
                    .toArray(String[]::new);

            return locations.length == 0 ? new String[]{DEFAULT_LOCATION} : locations;
        }
    }
}
