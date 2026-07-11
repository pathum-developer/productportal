package com.elvencode.productportal.common.web;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;

class CorrelationIdFilterTest {

    private final CorrelationIdFilter correlationIdFilter = new CorrelationIdFilter();

    @AfterEach
    void clearMdc() {
        MDC.clear();
    }

    @Test
    void shouldPropagateClientCorrelationIdToRequestResponseAndMdc() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/test");
        MockHttpServletResponse response = new MockHttpServletResponse();
        AtomicReference<String> mdcCorrelationId = new AtomicReference<>();

        request.addHeader(CorrelationIdContext.HEADER_NAME, "client-request-123");

        correlationIdFilter.doFilter(request, response, (servletRequest, servletResponse) -> {
            mdcCorrelationId.set(MDC.get(CorrelationIdContext.MDC_KEY));
            assertThat(servletRequest.getAttribute(CorrelationIdContext.REQUEST_ATTRIBUTE))
                    .isEqualTo("client-request-123");
        });

        assertThat(response.getHeader(CorrelationIdContext.HEADER_NAME)).isEqualTo("client-request-123");
        assertThat(mdcCorrelationId).hasValue("client-request-123");
        assertThat(MDC.get(CorrelationIdContext.MDC_KEY)).isNull();
    }

    @Test
    void shouldReplaceInvalidClientCorrelationId() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/test");
        MockHttpServletResponse response = new MockHttpServletResponse();
        AtomicReference<String> mdcCorrelationId = new AtomicReference<>();

        request.addHeader(CorrelationIdContext.HEADER_NAME, "invalid\r\ncorrelation-id");

        correlationIdFilter.doFilter(request, response,
                (servletRequest, servletResponse) -> mdcCorrelationId.set(MDC.get(CorrelationIdContext.MDC_KEY)));

        String responseHeaderCorrelationId = response.getHeader(CorrelationIdContext.HEADER_NAME);

        assertThat(responseHeaderCorrelationId).isNotBlank();
        assertThat(responseHeaderCorrelationId).isNotEqualTo("invalid\r\ncorrelation-id");
        assertThat(responseHeaderCorrelationId).matches("^[A-Za-z0-9._:-]{1,100}$");
        assertThat(mdcCorrelationId).hasValue(responseHeaderCorrelationId);
        assertThat(MDC.get(CorrelationIdContext.MDC_KEY)).isNull();
    }
}
