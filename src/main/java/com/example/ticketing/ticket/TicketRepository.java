package com.example.ticketing.ticket;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketRepository extends JpaRepository<Ticket, Long> {
    Optional<Ticket> findByTicketNumber(String ticketNumber);

    Page<Ticket> findByAssigneeName(String assigneeName, Pageable pageable);

    Page<Ticket> findByStatus(TicketTypes.TicketStatus status, Pageable pageable);

    Page<Ticket> findByAssigneeNameAndStatus(
        String assigneeName,
        TicketTypes.TicketStatus status,
        Pageable pageable
    );
}
