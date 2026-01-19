package com.example.ticketing.ticket;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketRepository extends JpaRepository<Ticket, Long> {
    Optional<Ticket> findByTicketNumber(String ticketNumber);

    List<Ticket> findByAssigneeName(String assigneeName);

    List<Ticket> findByStatus(TicketTypes.TicketStatus status);

    List<Ticket> findByAssigneeNameAndStatus(String assigneeName, TicketTypes.TicketStatus status);
}
