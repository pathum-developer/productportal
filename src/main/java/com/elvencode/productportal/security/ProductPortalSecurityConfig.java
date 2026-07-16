package com.elvencode.productportal.security;

import com.elvencode.productportal.auth.session.service.AuthSessionService;
import com.elvencode.productportal.common.web.HttpErrorResponseWriter;
import com.elvencode.productportal.security.config.CorsProperties;
import com.elvencode.productportal.security.config.SecurityPathPolicy;
import com.elvencode.productportal.security.filter.JwtTokenValidatorFilter;
import com.elvencode.productportal.security.service.CurrentUserAccessService;
import com.elvencode.productportal.security.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class ProductPortalSecurityConfig {

    private final JwtUtil jwtUtil;
    private final CurrentUserAccessService currentUserAccessService;
    private final AuthSessionService authSessionService;
    private final CorsProperties corsProperties;
    private final HttpErrorResponseWriter errorResponseWriter;

    @Bean
    SecurityFilterChain customSecurityFilterChain(HttpSecurity http) {
        return http.csrf(csrfConfig -> csrfConfig.disable())
                .cors(corsConfig -> corsConfig.configurationSource(corsConfigurationSource()))
                .sessionManagement(sessionConfig ->
                        sessionConfig.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(requests -> {
                    SecurityPathPolicy.permitAll()
                            .forEach(path -> requests.requestMatchers(path).permitAll());
                    SecurityPathPolicy.authenticated()
                            .forEach(path -> requests.requestMatchers(path).authenticated());
                    requests.anyRequest().denyAll();
                })
                .addFilterBefore(
                        new JwtTokenValidatorFilter(
                                SecurityPathPolicy.jwtBypass(),
                                jwtUtil,
                                currentUserAccessService,
                                authSessionService,
                                errorResponseWriter),
                        UsernamePasswordAuthenticationFilter.class)
                .formLogin(flc -> flc.disable())
                .httpBasic(httpBasic -> httpBasic.disable())
                .build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(corsProperties.allowedOrigins());
        config.setAllowedOriginPatterns(corsProperties.allowedOriginPatterns());
        config.setAllowedMethods(corsProperties.allowedMethods());
        config.setAllowedHeaders(corsProperties.allowedHeaders());
        config.setExposedHeaders(corsProperties.exposedHeaders());
        config.setAllowCredentials(corsProperties.allowCredentials());
        config.setMaxAge(corsProperties.maxAge().toSeconds());

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationProvider authenticationProvider) {
        return new ProviderManager(authenticationProvider);
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
