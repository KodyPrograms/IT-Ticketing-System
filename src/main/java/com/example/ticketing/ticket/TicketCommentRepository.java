package com.example.ticketing.ticket;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TicketCommentRepository extends JpaRepository<TicketComment, Long> {
    List<TicketComment> findByTicketIdOrderByCreatedAtDesc(Long ticketId);

    List<TicketComment> findByTicketIdAndVisibilityOrderByCreatedAtDesc(
        Long ticketId,
        TicketTypes.CommentVisibility visibility
    );
}
