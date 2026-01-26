UPDATE tickets
SET status = 'CLOSED', closed_at = COALESCE(closed_at, resolved_at, NOW())
WHERE status = 'RESOLVED';
