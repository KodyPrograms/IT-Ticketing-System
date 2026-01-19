CREATE TABLE tickets (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  ticket_number VARCHAR(32) NOT NULL UNIQUE,
  title VARCHAR(160) NOT NULL,
  description TEXT NOT NULL,
  priority VARCHAR(16) NOT NULL,
  category VARCHAR(16) NOT NULL,
  status VARCHAR(16) NOT NULL,
  requester_name VARCHAR(120) NOT NULL,
  requester_email VARCHAR(160),
  assignee_name VARCHAR(120),
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  resolved_at DATETIME,
  closed_at DATETIME
);

CREATE INDEX idx_tickets_status ON tickets (status);
CREATE INDEX idx_tickets_assignee ON tickets (assignee_name);
CREATE INDEX idx_tickets_created_at ON tickets (created_at);
