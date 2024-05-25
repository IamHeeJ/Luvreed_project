package com.example.luvreed.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class LoginRequestDto {
    @NotBlank(message = "There is no phone")
    private String email;

    @NotBlank(message = "There is no password")
    private String password;
}
