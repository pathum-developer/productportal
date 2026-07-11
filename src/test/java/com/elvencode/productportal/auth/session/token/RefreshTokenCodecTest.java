package com.elvencode.productportal.auth.session.token;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.BadCredentialsException;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RefreshTokenCodecTest {

    private final RefreshTokenCodec codec = new RefreshTokenCodec();

    @Test
    void shouldGenerateParseAndHashOpaqueRefreshToken() {
        UUID sessionId = UUID.fromString("9db45bc0-3625-47e5-a794-784f37f62734");

        RefreshTokenCodec.GeneratedRefreshToken generatedToken = codec.generate(sessionId);
        RefreshTokenCodec.ParsedRefreshToken parsedToken = codec.parse(generatedToken.token());

        assertThat(parsedToken.sessionId()).isEqualTo(sessionId);
        assertThat(parsedToken.secret()).isNotBlank();
        assertThat(generatedToken.secretHash()).hasSize(64);
        assertThat(generatedToken.token()).doesNotContain(generatedToken.secretHash());
        assertThat(codec.matches(parsedToken.secret(), generatedToken.secretHash())).isTrue();
    }

    @Test
    void shouldRejectMalformedRefreshToken() {
        assertThatThrownBy(() -> codec.parse("not-a-refresh-token"))
                .isInstanceOf(BadCredentialsException.class)
                .hasMessage("Invalid refresh token");
    }
}
