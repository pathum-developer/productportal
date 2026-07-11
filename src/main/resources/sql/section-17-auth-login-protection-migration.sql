-- Section 17 authentication login protection migration.
-- Adds durable failed-login throttle state and append-only login attempt audit events.

CREATE TABLE IF NOT EXISTS pp_t_login_throttle_state
(
    throttle_state_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scope                VARCHAR(30)     NOT NULL,
    identifier_value     VARCHAR(255)    NOT NULL,
    failed_attempt_count INT             NOT NULL DEFAULT 0,
    window_started_at    TIMESTAMP(6)    NULL     DEFAULT NULL,
    last_failed_at       TIMESTAMP(6)    NULL     DEFAULT NULL,
    locked_until         TIMESTAMP(6)    NULL     DEFAULT NULL,
    last_successful_at   TIMESTAMP(6)    NULL     DEFAULT NULL,
    version              BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at           TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by           VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at           TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by           VARCHAR(100)    NULL,

    CONSTRAINT pk_pp_t_login_throttle_state PRIMARY KEY (throttle_state_id),
    CONSTRAINT uk_pp_t_login_throttle_state_scope_identifier
        UNIQUE (scope, identifier_value),
    CONSTRAINT chk_pp_t_login_throttle_state_scope
        CHECK (scope IN ('USERNAME', 'IP_ADDRESS')),
    CONSTRAINT chk_pp_t_login_throttle_state_identifier_not_blank
        CHECK (TRIM(identifier_value) <> ''),
    CONSTRAINT chk_pp_t_login_throttle_state_failed_attempt_count
        CHECK (failed_attempt_count >= 0),
    CONSTRAINT chk_pp_t_login_throttle_state_created_by_not_blank
        CHECK (TRIM(created_by) <> ''),

    INDEX idx_pp_t_login_throttle_state_scope_locked_until (scope, locked_until),
    INDEX idx_pp_t_login_throttle_state_identifier (identifier_value)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_a_login_attempt
(
    login_attempt_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    username         VARCHAR(100)    NOT NULL,
    user_id          BIGINT UNSIGNED NULL,
    outcome          VARCHAR(40)     NOT NULL,
    client_ip        VARCHAR(45)     NULL,
    user_agent       VARCHAR(512)    NULL,
    locked_until     TIMESTAMP(6)    NULL     DEFAULT NULL,
    occurred_at      TIMESTAMP(6)    NOT NULL,
    created_at       TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by       VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',

    CONSTRAINT pk_pp_a_login_attempt PRIMARY KEY (login_attempt_id),
    CONSTRAINT fk_pp_a_login_attempt_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE SET NULL,
    CONSTRAINT chk_pp_a_login_attempt_username_not_blank
        CHECK (TRIM(username) <> ''),
    CONSTRAINT chk_pp_a_login_attempt_outcome
        CHECK (outcome IN (
            'SUCCESS',
            'BAD_CREDENTIALS',
            'ACCOUNT_DISABLED',
            'NO_ACTIVE_ROLE_ASSIGNMENT',
            'USERNAME_LOCKED',
            'IP_THROTTLED'
        )),
    CONSTRAINT chk_pp_a_login_attempt_client_ip_not_blank
        CHECK (client_ip IS NULL OR TRIM(client_ip) <> ''),
    CONSTRAINT chk_pp_a_login_attempt_user_agent_not_blank
        CHECK (user_agent IS NULL OR TRIM(user_agent) <> ''),
    CONSTRAINT chk_pp_a_login_attempt_created_by_not_blank
        CHECK (TRIM(created_by) <> ''),

    INDEX idx_pp_a_login_attempt_username_time (username, occurred_at),
    INDEX idx_pp_a_login_attempt_client_ip_time (client_ip, occurred_at),
    INDEX idx_pp_a_login_attempt_outcome_time (outcome, occurred_at),
    INDEX idx_pp_a_login_attempt_user_id_time (user_id, occurred_at)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
