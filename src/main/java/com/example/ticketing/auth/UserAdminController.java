package com.example.ticketing.auth;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/users")
@Validated
public class UserAdminController {
    private final UserAdminService userAdminService;

    public UserAdminController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    @PostMapping
    public ResponseEntity<UserDtos.UserResponse> createUser(
        @Valid @RequestBody UserDtos.UserCreateRequest request,
        Authentication authentication
    ) {
        requireAdmin(authentication);
        UserAccount user = userAdminService.createUser(
            request.getUsername(),
            request.getPassword(),
            request.getRole(),
            request.getEnabled()
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(UserDtos.UserResponse.from(user));
    }

    @GetMapping
    public List<UserDtos.UserResponse> listUsers(Authentication authentication) {
        requireAdmin(authentication);
        return userAdminService.listUsers().stream()
            .map(UserDtos.UserResponse::from)
            .toList();
    }

    @PatchMapping("/{id}/enabled")
    public UserDtos.UserResponse updateEnabled(
        @PathVariable Long id,
        @Valid @RequestBody UserDtos.UserEnabledRequest request,
        Authentication authentication
    ) {
        requireAdmin(authentication);
        return UserDtos.UserResponse.from(userAdminService.updateEnabled(id, request.getEnabled()));
    }

    @PatchMapping("/{id}/password")
    public UserDtos.UserResponse resetPassword(
        @PathVariable Long id,
        @Valid @RequestBody UserDtos.UserPasswordResetRequest request,
        Authentication authentication
    ) {
        requireAdmin(authentication);
        return UserDtos.UserResponse.from(userAdminService.resetPassword(id, request.getPassword()));
    }

    private void requireAdmin(Authentication authentication) {
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            if ("ROLE_ADMIN".equals(authority.getAuthority())) {
                return;
            }
        }
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Admin role required.");
    }
}
