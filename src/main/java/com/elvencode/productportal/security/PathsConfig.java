package com.elvencode.productportal.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class PathsConfig {

    @Bean(name = "publicPaths")
    public List<String> publicPaths() {
        return List.of(
               // "/api/publica/**",
                "/api/auth/login",
                "/api/users/register",
                "/api/contacts/public",
                "/api/logging/public",

                // Swagger / Springdoc endpoints can be served with and without the global /api prefix.
                "/api/swagger-ui.html",
                "/api/swagger-ui/**",
                "/swagger-ui/**",
                "/api/v3/api-docs",
                "/api/v3/api-docs/**",
                "/v3/api-docs",
                "/v3/api-docs/**",
                "/swagger-resources/**",
                "/swagger-ui.html",
                "/webjars/**"
        );
    }

    @Bean(name = "securedPaths")
    public List<String> securedPaths() {
        return List.of(
                "/api/**"
        );
    }

}
