package com.example.ticketing.ticket;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketAuditRepository extends JpaRepository<TicketAudit, Long> {
    List<TicketAudit> findByTicketIdOrderByCreatedAtDesc(Long ticketId);
}
