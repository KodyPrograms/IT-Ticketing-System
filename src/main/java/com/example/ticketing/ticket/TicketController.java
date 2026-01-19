package com.example.ticketing.ticket;

import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/tickets")
@Validated
public class TicketController {
    private final TicketService ticketService;

    public TicketController(TicketService ticketService) {
        this.ticketService = ticketService;
    }

    @PostMapping
    public ResponseEntity<TicketDtos.TicketResponse> createTicket(
        @Valid @RequestBody TicketDtos.TicketCreateRequest request
    ) {
        Ticket ticket = new Ticket();
        ticket.setTitle(request.getTitle());
        ticket.setDescription(request.getDescription());
        ticket.setPriority(request.getPriority());
        ticket.setCategory(request.getCategory());
        ticket.setRequesterName(request.getRequesterName());
        ticket.setRequesterEmail(request.getRequesterEmail());
        ticket.setAssigneeName(request.getAssigneeName());

        Ticket created = ticketService.createTicket(ticket);
        return ResponseEntity.status(HttpStatus.CREATED).body(TicketDtos.TicketResponse.from(created));
    }

    @GetMapping
    public List<TicketDtos.TicketResponse> listTickets(
        @RequestParam(required = false) String assignee,
        @RequestParam(required = false) TicketTypes.TicketStatus status
    ) {
        return ticketService.listTickets(assignee, status).stream()
            .map(TicketDtos.TicketResponse::from)
            .toList();
    }

    @GetMapping("/{id}")
    public TicketDtos.TicketResponse getTicket(@PathVariable Long id) {
        return TicketDtos.TicketResponse.from(ticketService.getTicket(id));
    }

    @PatchMapping("/{id}/status")
    public TicketDtos.TicketResponse updateStatus(
        @PathVariable Long id,
        @Valid @RequestBody TicketDtos.TicketStatusUpdateRequest request,
        Authentication authentication
    ) {
        Ticket updated = ticketService.updateStatus(
            id,
            request.getStatus(),
            resolveActorRole(authentication),
            authentication.getName()
        );
        return TicketDtos.TicketResponse.from(updated);
    }

    @PatchMapping("/{id}/priority")
    public TicketDtos.TicketResponse updatePriority(
        @PathVariable Long id,
        @Valid @RequestBody TicketDtos.TicketPriorityUpdateRequest request,
        Authentication authentication
    ) {
        Ticket updated = ticketService.updatePriority(
            id,
            request.getPriority(),
            resolveActorRole(authentication),
            authentication.getName()
        );
        return TicketDtos.TicketResponse.from(updated);
    }

    @PatchMapping("/{id}/assignee")
    public TicketDtos.TicketResponse updateAssignee(
        @PathVariable Long id,
        @Valid @RequestBody TicketDtos.TicketAssigneeUpdateRequest request,
        Authentication authentication
    ) {
        Ticket updated = ticketService.assignTicket(
            id,
            request.getAssigneeName(),
            resolveActorRole(authentication),
            authentication.getName()
        );
        return TicketDtos.TicketResponse.from(updated);
    }

    @GetMapping("/{id}/assignments")
    public List<TicketDtos.TicketAssignmentResponse> listAssignments(@PathVariable Long id) {
        return ticketService.listAssignments(id).stream()
            .map(TicketDtos.TicketAssignmentResponse::from)
            .toList();
    }

    @PostMapping("/{id}/comments")
    public ResponseEntity<TicketDtos.TicketCommentResponse> addComment(
        @PathVariable Long id,
        @Valid @RequestBody TicketDtos.TicketCommentCreateRequest request,
        Authentication authentication
    ) {
        TicketComment comment = ticketService.addComment(
            id,
            request.getVisibility(),
            request.getBody(),
            resolveActorRole(authentication),
            authentication.getName()
        );
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(TicketDtos.TicketCommentResponse.from(comment));
    }

    @GetMapping("/{id}/comments")
    public List<TicketDtos.TicketCommentResponse> listComments(
        @PathVariable Long id,
        @RequestParam(required = false) TicketTypes.CommentVisibility visibility,
        Authentication authentication
    ) {
        return ticketService.listComments(id, resolveActorRole(authentication), visibility).stream()
            .map(TicketDtos.TicketCommentResponse::from)
            .toList();
    }

    @GetMapping("/{id}/audit")
    public List<TicketDtos.TicketAuditResponse> listAudit(@PathVariable Long id) {
        return ticketService.listAudit(id).stream()
            .map(TicketDtos.TicketAuditResponse::from)
            .toList();
    }

    @GetMapping("/reports/status-counts")
    public List<TicketDtos.TicketStatusCountResponse> statusCounts() {
        Map<TicketTypes.TicketStatus, Long> counts = new HashMap<>();
        for (Ticket ticket : ticketService.listTickets()) {
            counts.merge(ticket.getStatus(), 1L, Long::sum);
        }
        return counts.entrySet().stream()
            .map(entry -> new TicketDtos.TicketStatusCountResponse(entry.getKey(), entry.getValue()))
            .toList();
    }

    @GetMapping("/reports/assignee-workload")
    public List<TicketDtos.TicketAssigneeWorkloadResponse> assigneeWorkload() {
        Map<String, Long> counts = new HashMap<>();
        for (Ticket ticket : ticketService.listTickets()) {
            String assignee = ticket.getAssigneeName();
            if (assignee == null || assignee.isBlank()) {
                assignee = "Unassigned";
            }
            counts.merge(assignee, 1L, Long::sum);
        }
        return counts.entrySet().stream()
            .map(entry -> new TicketDtos.TicketAssigneeWorkloadResponse(entry.getKey(), entry.getValue()))
            .toList();
    }

    @GetMapping("/reports/resolution-time")
    public TicketDtos.TicketResolutionTimeResponse resolutionTime() {
        long resolvedCount = 0;
        long totalSeconds = 0;
        for (Ticket ticket : ticketService.listTickets()) {
            if (ticket.getResolvedAt() != null && ticket.getCreatedAt() != null) {
                resolvedCount += 1;
                totalSeconds += Duration.between(ticket.getCreatedAt(), ticket.getResolvedAt()).getSeconds();
            }
        }
        double averageSeconds = resolvedCount == 0 ? 0 : (double) totalSeconds / resolvedCount;
        double averageMinutes = averageSeconds / 60.0;
        double averageHours = averageMinutes / 60.0;
        return new TicketDtos.TicketResolutionTimeResponse(
            resolvedCount,
            averageSeconds,
            averageMinutes,
            averageHours
        );
    }

    private TicketTypes.TicketRole resolveActorRole(Authentication authentication) {
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            String role = authority.getAuthority();
            if (role.startsWith("ROLE_")) {
                return TicketTypes.TicketRole.valueOf(role.substring(5));
            }
        }
        throw new TicketRuleViolationException("Authenticated user does not have a role.");
    }
}
