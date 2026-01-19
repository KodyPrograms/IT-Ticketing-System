CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(80) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(16) NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE
);

INSERT INTO users (username, password_hash, role, enabled)
VALUES
  ('requester', '$2y$05$5VjhEvE5phC2Fpw753anVe/Z.7A64eJP3/uQQDFZkZedxzGuic4He', 'REQUESTER', TRUE),
  ('engineer',  '$2y$05$i8iYlt7dN3sw9mse3hk2IeaIZ3wO/i..RJQv4VuXnweBZ4em3fCLC', 'ENGINEER', TRUE),
  ('admin',     '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'ADMIN', TRUE);
