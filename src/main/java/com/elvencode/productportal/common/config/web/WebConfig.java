package com.elvencode.productportal.common.config.web;

import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.config.annotation.ApiVersionConfigurer;
import org.springframework.web.servlet.config.annotation.PathMatchConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private static final String API_PATH_PREFIX = "/api";
    private static final List<String> API_CONTROLLER_PACKAGE_ROOTS = List.of(
            "com.elvencode.productportal.auth",
            "com.elvencode.productportal.user",
            "com.elvencode.productportal.catalog",
            "com.elvencode.productportal.access",
            "com.elvencode.productportal.organization");

    @Override
    public void configureApiVersioning(ApiVersionConfigurer configurer) {
        configurer.useMediaTypeParameter(MediaType.parseMediaType("application/vnd.productportal+json"), "v")
                .addSupportedVersions("1.0", "2.0", "3.0")
                .setDefaultVersion("1.0");
    }

    @Override
    public void configurePathMatch(PathMatchConfigurer configurer) {
        configurer.addPathPrefix(API_PATH_PREFIX, WebConfig::isProductionApiController);
    }

    private static boolean isProductionApiController(Class<?> handlerType) {
        return AnnotationUtils.findAnnotation(handlerType, RestController.class) != null
                && isProductionApiPackage(handlerType.getPackageName());
    }

    private static boolean isProductionApiPackage(String packageName) {
        return API_CONTROLLER_PACKAGE_ROOTS.stream()
                .anyMatch(root -> packageName.equals(root) || packageName.startsWith(root + "."));
    }
}
