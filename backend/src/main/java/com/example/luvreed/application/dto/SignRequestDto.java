package com.example.luvreed.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class SignRequestDto {

    @NotBlank(message = "There is no email")
    // 여기에 전화번호 검증하는 어노테이션이나 함수도 있으면 좋을 듯
    private String email;

    @NotBlank(message = "There is no password")
    private String password;
}
