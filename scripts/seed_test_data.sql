-- Seed realistic demo data for the ticketing system.
-- Password for all users below: admin123

USE ticketing;

START TRANSACTION;

INSERT INTO users (username, password_hash, role, enabled, display_name, title, avatar_url, email)
VALUES
  ('admin', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'ADMIN', TRUE,
   'Sophia Grant', 'IT Operations Manager', 'https://i.pravatar.cc/150?img=5', 'sophia.grant@company.local'),
  ('engineer', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'ENGINEER', TRUE,
   'Maya Patel', 'Systems Engineer', 'https://i.pravatar.cc/150?img=13', 'maya.patel@company.local'),
  ('requester', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'REQUESTER', TRUE,
   'Ava Carter', 'Project Coordinator', 'https://i.pravatar.cc/150?img=47', 'ava.carter@company.local'),
  ('liam', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'ENGINEER', TRUE,
   'Liam Chen', 'Network Engineer', 'https://i.pravatar.cc/150?img=15', 'liam.chen@company.local'),
  ('noah', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'ENGINEER', TRUE,
   'Noah Alvarez', 'Support Engineer', 'https://i.pravatar.cc/150?img=12', 'noah.alvarez@company.local'),
  ('emma', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'REQUESTER', TRUE,
   'Emma Brooks', 'HR Specialist', 'https://i.pravatar.cc/150?img=32', 'emma.brooks@company.local'),
  ('carlos', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'REQUESTER', TRUE,
   'Carlos Nguyen', 'Finance Analyst', 'https://i.pravatar.cc/150?img=7', 'carlos.nguyen@company.local'),
  ('zara', '$2y$05$2F49.yTINiDOhZNwpePByOmX6/rLYdILpP9SjOBc42HdOaZtt2agW', 'REQUESTER', TRUE,
   'Zara Ahmed', 'Customer Success Lead', 'https://i.pravatar.cc/150?img=24', 'zara.ahmed@company.local')
ON DUPLICATE KEY UPDATE
  password_hash = VALUES(password_hash),
  role = VALUES(role),
  enabled = VALUES(enabled),
  display_name = VALUES(display_name),
  title = VALUES(title),
  avatar_url = VALUES(avatar_url),
  email = VALUES(email);

DELETE FROM ticket_comments
WHERE ticket_id IN (
  SELECT id FROM tickets WHERE ticket_number IN (
    'TCK-2026-0001','TCK-2026-0002','TCK-2026-0003','TCK-2026-0004','TCK-2026-0005',
    'TCK-2026-0006','TCK-2026-0007','TCK-2026-0008','TCK-2026-0009','TCK-2026-0010'
  )
);
DELETE FROM ticket_audit
WHERE ticket_id IN (
  SELECT id FROM tickets WHERE ticket_number IN (
    'TCK-2026-0001','TCK-2026-0002','TCK-2026-0003','TCK-2026-0004','TCK-2026-0005',
    'TCK-2026-0006','TCK-2026-0007','TCK-2026-0008','TCK-2026-0009','TCK-2026-0010'
  )
);
DELETE FROM ticket_assignments
WHERE ticket_id IN (
  SELECT id FROM tickets WHERE ticket_number IN (
    'TCK-2026-0001','TCK-2026-0002','TCK-2026-0003','TCK-2026-0004','TCK-2026-0005',
    'TCK-2026-0006','TCK-2026-0007','TCK-2026-0008','TCK-2026-0009','TCK-2026-0010'
  )
);
DELETE FROM tickets
WHERE ticket_number IN (
  'TCK-2026-0001','TCK-2026-0002','TCK-2026-0003','TCK-2026-0004','TCK-2026-0005',
  'TCK-2026-0006','TCK-2026-0007','TCK-2026-0008','TCK-2026-0009','TCK-2026-0010'
);

INSERT INTO tickets (
  ticket_number, title, description, priority, category, status,
  requester_name, requester_email, assignee_name, created_at, updated_at, resolved_at, closed_at
)
VALUES
  ('TCK-2026-0001', 'VPN access for new hire',
   'Provision VPN and MFA access for new marketing hire starting next Monday.',
   'HIGH', 'ACCESS', 'CLOSED',
   'Ava Carter', 'ava.carter@company.local', 'Liam Chen',
   DATE_SUB(NOW(), INTERVAL 18 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
  ('TCK-2026-0002', 'Laptop Wi-Fi drops in conference rooms',
   'Device disconnects every few minutes in the 3rd floor conference rooms.',
   'MEDIUM', 'NETWORK', 'IN_PROGRESS',
   'Carlos Nguyen', 'carlos.nguyen@company.local', 'Liam Chen',
   DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL),
  ('TCK-2026-0003', 'CRM timeout errors',
   'CRM pages intermittently timeout during peak hours.',
   'URGENT', 'SOFTWARE', 'BLOCKED',
   'Emma Brooks', 'emma.brooks@company.local', 'Maya Patel',
   DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, NULL),
  ('TCK-2026-0004', 'Replace worn keyboard',
   'Mechanical keyboard has multiple stuck keys, needs replacement.',
   'LOW', 'HARDWARE', 'NEW',
   'Zara Ahmed', 'zara.ahmed@company.local', NULL,
   DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, NULL),
  ('TCK-2026-0005', 'Onboard new finance user',
   'Create accounts and assign finance group access for new contractor.',
   'MEDIUM', 'ACCESS', 'IN_PROGRESS',
   'Carlos Nguyen', 'carlos.nguyen@company.local', 'Noah Alvarez',
   DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL),
  ('TCK-2026-0006', 'Email signature update',
   'Update signature template for HR team to include new compliance line.',
   'LOW', 'SOFTWARE', 'CLOSED',
   'Emma Brooks', 'emma.brooks@company.local', 'Maya Patel',
   DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY)),
  ('TCK-2026-0007', 'Office printer not found',
   'Printer HP-LJ-401 is missing from printer list after Windows update.',
   'MEDIUM', 'HARDWARE', 'IN_PROGRESS',
   'Ava Carter', 'ava.carter@company.local', 'Noah Alvarez',
   DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL),
  ('TCK-2026-0008', 'New project share drive',
   'Need a shared drive for Q1 Enablement initiative with read/write for marketing.',
   'HIGH', 'ACCESS', 'IN_PROGRESS',
   'Zara Ahmed', 'zara.ahmed@company.local', 'Maya Patel',
   DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL),
  ('TCK-2026-0009', 'Performance issues on analytics dashboard',
   'Dashboard loads slowly for large datasets; request index review.',
   'HIGH', 'SOFTWARE', 'BLOCKED',
   'Carlos Nguyen', 'carlos.nguyen@company.local', 'Liam Chen',
   DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, NULL),
  ('TCK-2026-0010', 'Badge access to HQ',
   'Add HQ access to badge for new customer success lead.',
   'MEDIUM', 'ACCESS', 'NEW',
   'Zara Ahmed', 'zara.ahmed@company.local', NULL,
   DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, NULL);

SET @t1 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001');
SET @t2 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002');
SET @t3 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003');
SET @t4 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0004');
SET @t5 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0005');
SET @t6 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006');
SET @t7 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007');
SET @t8 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0008');
SET @t9 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009');
SET @t10 := (SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0010');

INSERT INTO ticket_assignments (ticket_id, previous_assignee, new_assignee, actor_role, actor_name, created_at)
VALUES
  (@t1, NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 17 DAY)),
  (@t2, NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 9 DAY)),
  (@t3, NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (@t5, NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (@t6, NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 19 DAY)),
  (@t7, NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t8, NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (@t9, NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 11 DAY));

INSERT INTO ticket_audit (ticket_id, action, field_name, old_value, new_value, actor_role, actor_name, created_at)
VALUES
  (@t1, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Ava Carter', DATE_SUB(NOW(), INTERVAL 18 DAY)),
  (@t1, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 17 DAY)),
  (@t1, 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 12 DAY)),
  (@t1, 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'CLOSED', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 8 DAY)),
  (@t2, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', DATE_SUB(NOW(), INTERVAL 10 DAY)),
  (@t2, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 9 DAY)),
  (@t2, 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (@t3, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Emma Brooks', DATE_SUB(NOW(), INTERVAL 6 DAY)),
  (@t3, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (@t3, 'STATUS_CHANGED', 'status', 'NEW', 'BLOCKED', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t4, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t5, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (@t5, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (@t6, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Emma Brooks', DATE_SUB(NOW(), INTERVAL 20 DAY)),
  (@t6, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 19 DAY)),
  (@t6, 'STATUS_CHANGED', 'status', 'NEW', 'CLOSED', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 14 DAY)),
  (@t7, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Ava Carter', DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (@t7, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t7, 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Noah Alvarez', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (@t8, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', DATE_SUB(NOW(), INTERVAL 5 DAY)),
  (@t8, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (@t9, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', DATE_SUB(NOW(), INTERVAL 12 DAY)),
  (@t9, 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', DATE_SUB(NOW(), INTERVAL 11 DAY)),
  (@t9, 'STATUS_CHANGED', 'status', 'NEW', 'BLOCKED', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t10, 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', DATE_SUB(NOW(), INTERVAL 1 DAY));

INSERT INTO ticket_comments (ticket_id, visibility, body, actor_role, actor_name, created_at)
VALUES
  (@t1, 'PUBLIC', 'Access confirmed. Please log out/in after MFA enrollment.', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 9 DAY)),
  (@t2, 'INTERNAL', 'Seeing AP drops on 3rd floor. Checking controller logs.', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t3, 'PUBLIC', 'We need vendor input; awaiting escalation.', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t5, 'PUBLIC', 'Provisioning accounts now. Will confirm once done.', 'ENGINEER', 'Noah Alvarez', DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (@t6, 'PUBLIC', 'Signature template updated and deployed.', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 14 DAY)),
  (@t7, 'INTERNAL', 'Driver reinstall fixed on test device; rolling out.', 'ENGINEER', 'Noah Alvarez', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (@t8, 'PUBLIC', 'Share created, waiting for approvals.', 'ENGINEER', 'Maya Patel', DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (@t9, 'INTERNAL', 'Backend DB index review scheduled with data team.', 'ENGINEER', 'Liam Chen', DATE_SUB(NOW(), INTERVAL 2 DAY));

INSERT INTO user_audit (action, actor_username, actor_role, target_username, created_at)
VALUES
  ('USER_CREATED', 'admin', 'ADMIN', 'liam', DATE_SUB(NOW(), INTERVAL 25 DAY)),
  ('USER_CREATED', 'admin', 'ADMIN', 'noah', DATE_SUB(NOW(), INTERVAL 24 DAY)),
  ('USER_CREATED', 'admin', 'ADMIN', 'emma', DATE_SUB(NOW(), INTERVAL 23 DAY)),
  ('USER_CREATED', 'admin', 'ADMIN', 'carlos', DATE_SUB(NOW(), INTERVAL 23 DAY)),
  ('USER_CREATED', 'admin', 'ADMIN', 'zara', DATE_SUB(NOW(), INTERVAL 22 DAY)),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'liam', DATE_SUB(NOW(), INTERVAL 24 DAY)),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'noah', DATE_SUB(NOW(), INTERVAL 24 DAY)),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'emma', DATE_SUB(NOW(), INTERVAL 22 DAY)),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'carlos', DATE_SUB(NOW(), INTERVAL 22 DAY)),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'zara', DATE_SUB(NOW(), INTERVAL 22 DAY));

COMMIT;
