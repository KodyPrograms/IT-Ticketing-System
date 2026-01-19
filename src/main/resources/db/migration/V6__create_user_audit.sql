CREATE TABLE user_audit (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  action VARCHAR(32) NOT NULL,
  actor_username VARCHAR(80) NOT NULL,
  actor_role VARCHAR(16) NOT NULL,
  target_username VARCHAR(80) NOT NULL,
  created_at DATETIME NOT NULL
);

CREATE INDEX idx_user_audit_target_username ON user_audit (target_username);
CREATE INDEX idx_user_audit_created_at ON user_audit (created_at);
