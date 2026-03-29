UPDATE users
SET password_hash = CASE username
  WHEN 'admin' THEN '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha'
  WHEN 'engineer' THEN '$2y$05$pHZIwWo2nGrCmOCHWSRdVenpUbpNdW/mCBp1isDO/pAk57B6etZei'
  WHEN 'requester' THEN '$2y$05$7sqaEdZLuV8K0.qMkA44XeJ4S.4dnPdPUjap/i4xkwM6AnvmC3C5y'
  ELSE password_hash
END
WHERE username IN ('admin', 'engineer', 'requester');

INSERT INTO users (username, password_hash, role, enabled, display_name, title, avatar_url, email)
VALUES
  ('admin', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'ADMIN', TRUE,
   'Sophia Grant', 'IT Operations Manager', 'https://i.pravatar.cc/150?img=5', 'sophia.grant@company.local'),
  ('engineer', '$2y$05$pHZIwWo2nGrCmOCHWSRdVenpUbpNdW/mCBp1isDO/pAk57B6etZei', 'ENGINEER', TRUE,
   'Maya Patel', 'Systems Engineer', 'https://i.pravatar.cc/150?img=13', 'maya.patel@company.local'),
  ('requester', '$2y$05$7sqaEdZLuV8K0.qMkA44XeJ4S.4dnPdPUjap/i4xkwM6AnvmC3C5y', 'REQUESTER', TRUE,
   'Ava Carter', 'Project Coordinator', 'https://i.pravatar.cc/150?img=47', 'ava.carter@company.local'),
  ('liam', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'ENGINEER', TRUE,
   'Liam Chen', 'Network Engineer', 'https://i.pravatar.cc/150?img=15', 'liam.chen@company.local'),
  ('noah', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'ENGINEER', TRUE,
   'Noah Alvarez', 'Support Engineer', 'https://i.pravatar.cc/150?img=12', 'noah.alvarez@company.local'),
  ('emma', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'REQUESTER', TRUE,
   'Emma Brooks', 'HR Specialist', 'https://i.pravatar.cc/150?img=32', 'emma.brooks@company.local'),
  ('carlos', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'REQUESTER', TRUE,
   'Carlos Nguyen', 'Finance Analyst', 'https://i.pravatar.cc/150?img=7', 'carlos.nguyen@company.local'),
  ('zara', '$2y$05$EaMWbX3oEm6So3PzNwQA.u4/kCUrJ0mbobDEMCD2yU8PKfE2FDLha', 'REQUESTER', TRUE,
   'Zara Ahmed', 'Customer Success Lead', 'https://i.pravatar.cc/150?img=24', 'zara.ahmed@company.local')
ON CONFLICT (username) DO UPDATE
SET
  password_hash = EXCLUDED.password_hash,
  role = EXCLUDED.role,
  enabled = EXCLUDED.enabled,
  display_name = EXCLUDED.display_name,
  title = EXCLUDED.title,
  avatar_url = EXCLUDED.avatar_url,
  email = EXCLUDED.email;

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
  requester_name, requester_username, requester_email, assignee_name, created_at, updated_at, resolved_at, closed_at
)
VALUES
  ('TCK-2026-0001', 'VPN access for new hire',
   'Provision VPN and MFA access for new marketing hire starting next Monday.',
   'HIGH', 'ACCESS', 'CLOSED',
   'Ava Carter', 'requester', 'ava.carter@company.local', 'Liam Chen',
   NOW() - INTERVAL '18 days', NOW() - INTERVAL '8 days', NOW() - INTERVAL '9 days', NOW() - INTERVAL '8 days'),
  ('TCK-2026-0002', 'Laptop Wi-Fi drops in conference rooms',
   'Device disconnects every few minutes in the 3rd floor conference rooms.',
   'MEDIUM', 'NETWORK', 'IN_PROGRESS',
   'Carlos Nguyen', 'carlos', 'carlos.nguyen@company.local', 'Liam Chen',
   NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day', NULL, NULL),
  ('TCK-2026-0003', 'CRM timeout errors',
   'CRM pages intermittently timeout during peak hours.',
   'URGENT', 'SOFTWARE', 'BLOCKED',
   'Emma Brooks', 'emma', 'emma.brooks@company.local', 'Maya Patel',
   NOW() - INTERVAL '6 days', NOW() - INTERVAL '2 days', NULL, NULL),
  ('TCK-2026-0004', 'Replace worn keyboard',
   'Mechanical keyboard has multiple stuck keys, needs replacement.',
   'LOW', 'HARDWARE', 'NEW',
   'Zara Ahmed', 'zara', 'zara.ahmed@company.local', NULL,
   NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NULL, NULL),
  ('TCK-2026-0005', 'Onboard new finance user',
   'Create accounts and assign finance group access for new contractor.',
   'MEDIUM', 'ACCESS', 'IN_PROGRESS',
   'Carlos Nguyen', 'carlos', 'carlos.nguyen@company.local', 'Noah Alvarez',
   NOW() - INTERVAL '4 days', NOW() - INTERVAL '1 day', NULL, NULL),
  ('TCK-2026-0006', 'Email signature update',
   'Update signature template for HR team to include new compliance line.',
   'LOW', 'SOFTWARE', 'CLOSED',
   'Emma Brooks', 'emma', 'emma.brooks@company.local', 'Maya Patel',
   NOW() - INTERVAL '20 days', NOW() - INTERVAL '14 days', NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days'),
  ('TCK-2026-0007', 'Office printer not found',
   'Printer HP-LJ-401 is missing from printer list after Windows update.',
   'MEDIUM', 'HARDWARE', 'IN_PROGRESS',
   'Ava Carter', 'requester', 'ava.carter@company.local', 'Noah Alvarez',
   NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', NULL, NULL),
  ('TCK-2026-0008', 'New project share drive',
   'Need a shared drive for Q1 Enablement initiative with read/write for marketing.',
   'HIGH', 'ACCESS', 'IN_PROGRESS',
   'Zara Ahmed', 'zara', 'zara.ahmed@company.local', 'Maya Patel',
   NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 day', NULL, NULL),
  ('TCK-2026-0009', 'Performance issues on analytics dashboard',
   'Dashboard loads slowly for large datasets; request index review.',
   'HIGH', 'SOFTWARE', 'BLOCKED',
   'Carlos Nguyen', 'carlos', 'carlos.nguyen@company.local', 'Liam Chen',
   NOW() - INTERVAL '12 days', NOW() - INTERVAL '2 days', NULL, NULL),
  ('TCK-2026-0010', 'Badge access to HQ',
   'Add HQ access to badge for new customer success lead.',
   'MEDIUM', 'ACCESS', 'NEW',
   'Zara Ahmed', 'zara', 'zara.ahmed@company.local', NULL,
   NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NULL, NULL);

INSERT INTO ticket_assignments (ticket_id, previous_assignee, new_assignee, actor_role, actor_name, created_at)
VALUES
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '17 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002'), NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '9 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003'), NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '5 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0005'), NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '3 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006'), NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '19 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007'), NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0008'), NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '4 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009'), NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '11 days');

INSERT INTO ticket_audit (ticket_id, action, field_name, old_value, new_value, actor_role, actor_name, created_at)
VALUES
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Ava Carter', NOW() - INTERVAL '18 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '17 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '12 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), 'STATUS_CHANGED', 'status', 'IN_PROGRESS', 'CLOSED', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '8 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', NOW() - INTERVAL '10 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '9 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002'), 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '1 day'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Emma Brooks', NOW() - INTERVAL '6 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '5 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003'), 'STATUS_CHANGED', 'status', 'NEW', 'BLOCKED', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0004'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0005'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', NOW() - INTERVAL '4 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0005'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '3 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Emma Brooks', NOW() - INTERVAL '20 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '19 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006'), 'STATUS_CHANGED', 'status', 'NEW', 'CLOSED', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '14 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Ava Carter', NOW() - INTERVAL '3 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Noah Alvarez', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007'), 'STATUS_CHANGED', 'status', 'NEW', 'IN_PROGRESS', 'ENGINEER', 'Noah Alvarez', NOW() - INTERVAL '1 day'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0008'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', NOW() - INTERVAL '5 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0008'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Maya Patel', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '4 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Carlos Nguyen', NOW() - INTERVAL '12 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009'), 'ASSIGNEE_CHANGED', 'assignee', NULL, 'Liam Chen', 'ADMIN', 'Sophia Grant', NOW() - INTERVAL '11 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009'), 'STATUS_CHANGED', 'status', 'NEW', 'BLOCKED', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0010'), 'CREATED', NULL, NULL, NULL, 'REQUESTER', 'Zara Ahmed', NOW() - INTERVAL '1 day');

INSERT INTO ticket_comments (ticket_id, visibility, body, actor_role, actor_name, created_at)
VALUES
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0001'), 'PUBLIC', 'Access confirmed. Please log out/in after MFA enrollment.', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '9 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0002'), 'INTERNAL', 'Seeing AP drops on 3rd floor. Checking controller logs.', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0003'), 'PUBLIC', 'We need vendor input; awaiting escalation.', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0005'), 'PUBLIC', 'Provisioning accounts now. Will confirm once done.', 'ENGINEER', 'Noah Alvarez', NOW() - INTERVAL '2 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0006'), 'PUBLIC', 'Signature template updated and deployed.', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '14 days'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0007'), 'INTERNAL', 'Driver reinstall fixed on test device; rolling out.', 'ENGINEER', 'Noah Alvarez', NOW() - INTERVAL '1 day'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0008'), 'PUBLIC', 'Share created, waiting for approvals.', 'ENGINEER', 'Maya Patel', NOW() - INTERVAL '1 day'),
  ((SELECT id FROM tickets WHERE ticket_number = 'TCK-2026-0009'), 'INTERNAL', 'Backend DB index review scheduled with data team.', 'ENGINEER', 'Liam Chen', NOW() - INTERVAL '2 days');

INSERT INTO user_audit (action, actor_username, actor_role, target_username, created_at)
VALUES
  ('USER_CREATED', 'admin', 'ADMIN', 'liam', NOW() - INTERVAL '25 days'),
  ('USER_CREATED', 'admin', 'ADMIN', 'noah', NOW() - INTERVAL '24 days'),
  ('USER_CREATED', 'admin', 'ADMIN', 'emma', NOW() - INTERVAL '23 days'),
  ('USER_CREATED', 'admin', 'ADMIN', 'carlos', NOW() - INTERVAL '23 days'),
  ('USER_CREATED', 'admin', 'ADMIN', 'zara', NOW() - INTERVAL '22 days'),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'liam', NOW() - INTERVAL '24 days'),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'noah', NOW() - INTERVAL '24 days'),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'emma', NOW() - INTERVAL '22 days'),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'carlos', NOW() - INTERVAL '22 days'),
  ('PROFILE_UPDATED', 'admin', 'ADMIN', 'zara', NOW() - INTERVAL '22 days');
