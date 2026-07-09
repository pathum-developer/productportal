package com.elvencode.productportal;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing(auditorAwareRef = "auditorAwareImpl", modifyOnCreate = false)
public class ProductportalApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProductportalApplication.class, args);
    }

}
