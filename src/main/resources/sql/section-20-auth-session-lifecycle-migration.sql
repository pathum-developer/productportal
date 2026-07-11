-- Section 20 authentication session lifecycle migration.
-- Adds durable refresh-token sessions for rotation, logout, device tracking, and
-- password-change invalidation.

ALTER TABLE pp_m_user
    ADD COLUMN credentials_changed_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        AFTER password_hash;

CREATE TABLE IF NOT EXISTS pp_t_auth_session
(
    auth_session_id     CHAR(36)        NOT NULL,
    user_id             BIGINT UNSIGNED NOT NULL,
    refresh_token_hash  CHAR(64)        NOT NULL,
    issued_at           TIMESTAMP(6)    NOT NULL,
    refresh_expires_at  TIMESTAMP(6)    NOT NULL,
    last_used_at        TIMESTAMP(6)    NOT NULL,
    revoked_at          TIMESTAMP(6)    NULL     DEFAULT NULL,
    revocation_reason   VARCHAR(60)     NULL     DEFAULT NULL,
    client_ip           VARCHAR(45)     NULL     DEFAULT NULL,
    user_agent          VARCHAR(512)    NULL     DEFAULT NULL,
    version             BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at          TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by          VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at          TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by          VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_t_auth_session PRIMARY KEY (auth_session_id),
    CONSTRAINT fk_pp_t_auth_session_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    CONSTRAINT chk_pp_t_auth_session_refresh_token_hash_not_blank
        CHECK (TRIM(refresh_token_hash) <> ''),
    CONSTRAINT chk_pp_t_auth_session_refresh_window
        CHECK (refresh_expires_at > issued_at),
    CONSTRAINT chk_pp_t_auth_session_last_used_window
        CHECK (last_used_at >= issued_at),
    CONSTRAINT chk_pp_t_auth_session_revocation_reason
        CHECK (revocation_reason IS NULL OR revocation_reason IN (
            'LOGOUT',
            'REFRESH_TOKEN_REUSE_DETECTED',
            'PASSWORD_CHANGED',
            'SESSION_LIMIT_EXCEEDED',
            'ADMIN_REVOKED'
        )),
    CONSTRAINT chk_pp_t_auth_session_client_ip_not_blank
        CHECK (client_ip IS NULL OR TRIM(client_ip) <> ''),
    CONSTRAINT chk_pp_t_auth_session_user_agent_not_blank
        CHECK (user_agent IS NULL OR TRIM(user_agent) <> ''),
    CONSTRAINT chk_pp_t_auth_session_created_by_not_blank
        CHECK (TRIM(created_by) <> ''),

    INDEX idx_pp_t_auth_session_user_active (user_id, revoked_at, refresh_expires_at),
    INDEX idx_pp_t_auth_session_refresh_expires_at (refresh_expires_at)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
