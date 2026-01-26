ALTER TABLE tickets
  ADD COLUMN requester_username VARCHAR(80) NOT NULL DEFAULT '';

UPDATE tickets
SET requester_username = requester_name
WHERE requester_username = '';
