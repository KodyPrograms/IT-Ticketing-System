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

    public UserAdminService(
        UserAccountRepository userAccountRepository,
        PasswordEncoder passwordEncoder
    ) {
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
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

    public UserAccount updateEnabled(Long id, boolean enabled) {
        UserAccount user = getUser(id);
        user.setEnabled(enabled);
        return user;
    }

    public UserAccount resetPassword(Long id, String rawPassword) {
        UserAccount user = getUser(id);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        return user;
    }

    private UserAccount getUser(Long id) {
        return userAccountRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));
    }
}
