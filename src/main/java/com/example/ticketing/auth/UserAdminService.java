package com.example.ticketing.auth;

import java.util.List;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.example.ticketing.ticket.TicketTypes;

import org.springframework.http.HttpStatus;

@Service
@Transactional
public class UserAdminService {
    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserAuditService userAuditService;

    public UserAdminService(
        UserAccountRepository userAccountRepository,
        PasswordEncoder passwordEncoder,
        UserAuditService userAuditService
    ) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
        this.userAuditService = userAuditService;
    }

    public UserAccount createUser(
        String username,
        String rawPassword,
        TicketTypes.TicketRole role,
        Boolean enabled
    ) {
        if (userAccountRepository.findByUsername(username).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already exists.");
        }
        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        user.setRole(role);
        if (enabled != null) {
            user.setEnabled(enabled);
        }
        return userAccountRepository.save(user);
    }

    @Transactional(readOnly = true)
    public List<UserAccount> listUsers() {
        return userAccountRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<UserAudit> listAudit() {
        return userAuditService.listAll();
    }

    @Transactional(readOnly = true)
    public List<UserAudit> listAudit(String targetUsername) {
        return userAuditService.listForTarget(targetUsername);
    }

    public UserAccount updateEnabled(Long id, boolean enabled) {
        UserAccount user = getUser(id);
        user.setEnabled(enabled);
        return user;
    }

    public UserAccount resetPassword(
        Long id,
        String rawPassword,
        String actorUsername,
        TicketTypes.TicketRole actorRole
    ) {
        UserAccount user = getUser(id);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        userAuditService.log(
            UserAuditAction.PASSWORD_RESET,
            actorUsername,
            actorRole,
            user.getUsername()
        );
        return user;
    }

    private UserAccount getUser(Long id) {
        return userAccountRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));
    }
}
