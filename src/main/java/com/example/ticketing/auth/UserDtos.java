package com.example.ticketing.auth;

import com.example.ticketing.ticket.TicketTypes;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public final class UserDtos {
    private UserDtos() {
    }

    public static class UserCreateRequest {
        @NotBlank
        @Size(max = 80)
        private String username;

        @NotBlank
        @Size(min = 8, max = 128)
        private String password;

        @NotNull
        private TicketTypes.TicketRole role;

        private Boolean enabled;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public TicketTypes.TicketRole getRole() {
            return role;
        }

        public void setRole(TicketTypes.TicketRole role) {
            this.role = role;
        }

        public Boolean getEnabled() {
            return enabled;
        }

        public void setEnabled(Boolean enabled) {
            this.enabled = enabled;
        }
    }

    public static class UserEnabledRequest {
        @NotNull
        private Boolean enabled;

        public Boolean getEnabled() {
            return enabled;
        }

        public void setEnabled(Boolean enabled) {
            this.enabled = enabled;
        }
    }

    public static class UserPasswordResetRequest {
        @NotBlank
        @Size(min = 8, max = 128)
        private String password;

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }
    }

    public static class UserPasswordChangeRequest {
        @NotBlank
        private String currentPassword;

        @NotBlank
        @Size(min = 8, max = 128)
        private String newPassword;

        public String getCurrentPassword() {
            return currentPassword;
        }

        public void setCurrentPassword(String currentPassword) {
            this.currentPassword = currentPassword;
        }

        public String getNewPassword() {
            return newPassword;
        }

        public void setNewPassword(String newPassword) {
            this.newPassword = newPassword;
        }
    }

    public static class UserResponse {
        private Long id;
        private String username;
        private TicketTypes.TicketRole role;
        private boolean enabled;

        public static UserResponse from(UserAccount user) {
            UserResponse response = new UserResponse();
            response.id = user.getId();
            response.username = user.getUsername();
            response.role = user.getRole();
            response.enabled = user.isEnabled();
            return response;
        }

        public Long getId() {
            return id;
        }

        public String getUsername() {
            return username;
        }

        public TicketTypes.TicketRole getRole() {
            return role;
        }

        public boolean isEnabled() {
            return enabled;
        }
    }
}
