package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Role;
import com.example.luvreed.application.entity.User;
import lombok.*;
import java.io.Serializable;
import java.util.List;
import java.util.stream.Collectors;

@AllArgsConstructor
@Data
public class AccountUserDto {

    private Long id;
    private Long coupleId;
    private String email;
    private String name;
    private String password;
    private Role role;
    private String code;

    public AccountUserDto(User user) {
        this.id = user.getId();
        this.coupleId = user.getCouple().getId();
        this.password = user.getPassword();
        this.name = user.getName();
        this.email = user.getEmail();
        this.role = user.getRole();
        this.code = user.getCode();
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Request {

        private Long id;
        private Long coupleId;
        private String email;
        private String name;
        private String password;
        private Role role;
        private String code;

        public User toEntity() {
            User user = User.builder()
                    .id(id)
                    .password(password)
                    .name(name)
                    .email(email)
                    .role(role)
                    .code(code)
                    .build();
            return user;
        }
    }

    @Getter
    public static class Response implements Serializable {

        private final Long id;
        private final Long coupleId;
        private final String email;
        private final String name;
        private final String password;
        private final Role role;

        public Response(User user) {
            this.id = user.getId();
            this.coupleId = user.getCouple() != null ? user.getCouple().getId() : null;
            this.password = user.getPassword();
            this.email = user.getEmail();
            this.name = user.getName();
            this.role = user.getRole();
        }

        public static Response fromEntity(User user) {
            return new Response(user);
        }
    }

    public static List<Response> fromEntityList(List<User> userList) {
        return userList.stream()
                .map(Response::fromEntity)
                .collect(Collectors.toList());
    }
}
