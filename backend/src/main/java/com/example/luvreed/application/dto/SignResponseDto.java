package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Role;
import com.example.luvreed.application.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SignResponseDto {
    private Long id;
    private String email;
    private String name;
    private Role role;
    private String token;
    private Long chatroomId;
    public SignResponseDto(User user) {
        this.id = user.getId();
        this.email= user.getEmail();
        this.name = user.getName();
        this.role = user.getRole();
    }
}
