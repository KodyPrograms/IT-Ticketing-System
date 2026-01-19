package com.example.ticketing.ticket;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class TicketService {
    private final TicketRepository ticketRepository;
    private final TicketAssignmentRepository ticketAssignmentRepository;
    private final TicketAuditRepository ticketAuditRepository;
    private final TicketCommentRepository ticketCommentRepository;

    public TicketService(
        TicketRepository ticketRepository,
        TicketAssignmentRepository ticketAssignmentRepository,
        TicketAuditRepository ticketAuditRepository,
        TicketCommentRepository ticketCommentRepository
    ) {
        this.ticketRepository = ticketRepository;
        this.ticketAssignmentRepository = ticketAssignmentRepository;
        this.ticketAuditRepository = ticketAuditRepository;
        this.ticketCommentRepository = ticketCommentRepository;
    }

    public Ticket createTicket(Ticket ticket) {
        ticket.setTicketNumber(generateTicketNumber());
        ticket.setStatus(TicketTypes.TicketStatus.NEW);
        Ticket created = ticketRepository.save(ticket);
        logAudit(
            created.getId(),
            TicketTypes.AuditAction.CREATED,
            "ticket",
            null,
            created.getTicketNumber(),
            TicketTypes.TicketRole.REQUESTER,
            created.getRequesterName()
        );
        return created;
    }

    @Transactional(readOnly = true)
    public Page<Ticket> listTickets(
        String assigneeName,
        TicketTypes.TicketStatus status,
        Pageable pageable
    ) {
        if (assigneeName != null && status != null) {
            return ticketRepository.findByAssigneeNameAndStatus(assigneeName, status, pageable);
        }
        if (assigneeName != null) {
            return ticketRepository.findByAssigneeName(assigneeName, pageable);
        }
        if (status != null) {
            return ticketRepository.findByStatus(status, pageable);
        }
        return ticketRepository.findAll(pageable);
    }

    @Transactional(readOnly = true)
    public Ticket getTicket(Long id) {
        return ticketRepository.findById(id)
            .orElseThrow(() -> new TicketNotFoundException(id));
    }

    public Ticket assignTicket(
        Long id,
        String newAssignee,
        TicketTypes.TicketRole actorRole,
        String actorName
    ) {
        if (actorRole == TicketTypes.TicketRole.REQUESTER) {
            throw new TicketRuleViolationException("Requesters cannot assign tickets.");
        }

        Ticket ticket = getTicket(id);
        String previousAssignee = ticket.getAssigneeName();
        ticket.setAssigneeName(newAssignee);

        TicketAssignment assignment = new TicketAssignment();
        assignment.setTicketId(ticket.getId());
        assignment.setPreviousAssignee(previousAssignee);
        assignment.setNewAssignee(newAssignee);
        assignment.setActorRole(actorRole);
        assignment.setActorName(actorName);
        ticketAssignmentRepository.save(assignment);
        logAudit(
            ticket.getId(),
            TicketTypes.AuditAction.ASSIGNEE_CHANGED,
            "assigneeName",
            previousAssignee,
            newAssignee,
            actorRole,
            actorName
        );

        return ticket;
    }

    @Transactional(readOnly = true)
    public List<TicketAssignment> listAssignments(Long ticketId) {
        getTicket(ticketId);
        return ticketAssignmentRepository.findByTicketIdOrderByCreatedAtDesc(ticketId);
    }

    public TicketComment addComment(
        Long ticketId,
        TicketTypes.CommentVisibility visibility,
        String body,
        TicketTypes.TicketRole actorRole,
        String actorName
    ) {
        if (visibility == TicketTypes.CommentVisibility.INTERNAL
            && actorRole == TicketTypes.TicketRole.REQUESTER) {
            throw new TicketRuleViolationException("Requesters cannot add internal comments.");
        }

        Ticket ticket = getTicket(ticketId);
        TicketComment comment = new TicketComment();
        comment.setTicketId(ticket.getId());
        comment.setVisibility(visibility);
        comment.setBody(body);
        comment.setActorRole(actorRole);
        comment.setActorName(actorName);
        TicketComment saved = ticketCommentRepository.save(comment);

        logAudit(
            ticket.getId(),
            TicketTypes.AuditAction.COMMENT_ADDED,
            "comment",
            null,
            buildCommentAuditValue(visibility, body),
            actorRole,
            actorName
        );
        return saved;
    }

    @Transactional(readOnly = true)
    public List<TicketComment> listComments(
        Long ticketId,
        TicketTypes.TicketRole actorRole,
        TicketTypes.CommentVisibility visibility
    ) {
        getTicket(ticketId);
        if (actorRole == TicketTypes.TicketRole.REQUESTER) {
            return ticketCommentRepository.findByTicketIdAndVisibilityOrderByCreatedAtDesc(
                ticketId,
                TicketTypes.CommentVisibility.PUBLIC
            );
        }
        if (visibility != null) {
            return ticketCommentRepository.findByTicketIdAndVisibilityOrderByCreatedAtDesc(
                ticketId,
                visibility
            );
        }
        return ticketCommentRepository.findByTicketIdOrderByCreatedAtDesc(ticketId);
    }

    public Ticket updateStatus(
        Long id,
        TicketTypes.TicketStatus newStatus,
        TicketTypes.TicketRole actorRole,
        String actorName
    ) {
        Ticket ticket = getTicket(id);
        TicketTypes.TicketStatus currentStatus = ticket.getStatus();

        if (currentStatus == TicketTypes.TicketStatus.CLOSED) {
            throw new TicketRuleViolationException("Closed tickets cannot be modified.");
        }

        if (actorRole == TicketTypes.TicketRole.REQUESTER) {
            throw new TicketRuleViolationException("Requesters cannot change ticket status.");
        }

        if (currentStatus == TicketTypes.TicketStatus.NEW && actorRole != TicketTypes.TicketRole.ENGINEER) {
            throw new TicketRuleViolationException("Only engineers can move tickets out of NEW.");
        }

        if (newStatus == TicketTypes.TicketStatus.CLOSED) {
            if (actorRole != TicketTypes.TicketRole.ADMIN) {
                throw new TicketRuleViolationException("Only administrators can close tickets.");
            }
            if (currentStatus != TicketTypes.TicketStatus.RESOLVED) {
                throw new TicketRuleViolationException("Tickets must be RESOLVED before closing.");
            }
            ticket.setClosedAt(LocalDateTime.now());
        }

        if (newStatus == TicketTypes.TicketStatus.RESOLVED) {
            ticket.setResolvedAt(LocalDateTime.now());
        }

        ticket.setStatus(newStatus);
        logAudit(
            ticket.getId(),
            TicketTypes.AuditAction.STATUS_CHANGED,
            "status",
            currentStatus.name(),
            newStatus.name(),
            actorRole,
            actorName
        );
        return ticket;
    }

    public Ticket updatePriority(
        Long id,
        TicketTypes.TicketPriority newPriority,
        TicketTypes.TicketRole actorRole,
        String actorName
    ) {
        if (actorRole == TicketTypes.TicketRole.REQUESTER) {
            throw new TicketRuleViolationException("Requesters cannot change ticket priority.");
        }

        Ticket ticket = getTicket(id);
        TicketTypes.TicketPriority currentPriority = ticket.getPriority();
        ticket.setPriority(newPriority);
        logAudit(
            ticket.getId(),
            TicketTypes.AuditAction.PRIORITY_CHANGED,
            "priority",
            currentPriority == null ? null : currentPriority.name(),
            newPriority.name(),
            actorRole,
            actorName
        );
        return ticket;
    }

    @Transactional(readOnly = true)
    public List<TicketAudit> listAudit(Long ticketId) {
        getTicket(ticketId);
        return ticketAuditRepository.findByTicketIdOrderByCreatedAtDesc(ticketId);
    }

    private void logAudit(
        Long ticketId,
        TicketTypes.AuditAction action,
        String fieldName,
        String oldValue,
        String newValue,
        TicketTypes.TicketRole actorRole,
        String actorName
    ) {
        TicketAudit audit = new TicketAudit();
        audit.setTicketId(ticketId);
        audit.setAction(action);
        audit.setFieldName(fieldName);
        audit.setOldValue(oldValue);
        audit.setNewValue(newValue);
        audit.setActorRole(actorRole);
        audit.setActorName(actorName);
        ticketAuditRepository.save(audit);
    }

    private String buildCommentAuditValue(TicketTypes.CommentVisibility visibility, String body) {
        String trimmed = body == null ? "" : body.trim();
        if (trimmed.length() > 400) {
            trimmed = trimmed.substring(0, 400) + "...";
        }
        return visibility.name() + ":" + trimmed;
    }

    private String generateTicketNumber() {
        return "TCK-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12)
            .toUpperCase();
    }
}
