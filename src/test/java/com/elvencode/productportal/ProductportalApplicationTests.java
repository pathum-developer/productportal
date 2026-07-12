package com.elvencode.productportal;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = {
        "jwt.secret=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "security.cors.allowed-origins=https://portal.example.com"
})
class ProductportalApplicationTests {

    @Test
    void contextLoads() {
    }

}
