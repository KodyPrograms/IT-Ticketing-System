package com.example.ticketing.ticket;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketAssignmentRepository extends JpaRepository<TicketAssignment, Long> {
    List<TicketAssignment> findByTicketIdOrderByCreatedAtDesc(Long ticketId);
}
