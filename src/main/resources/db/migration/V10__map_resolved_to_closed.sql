UPDATE tickets
SET status = 'CLOSED', closed_at = COALESCE(closed_at, resolved_at, CURRENT_TIMESTAMP)
WHERE status = 'RESOLVED';
