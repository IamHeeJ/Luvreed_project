package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.LoginRequestDto;
import com.example.luvreed.application.dto.SignRequestDto;
import com.example.luvreed.application.service.SignupService;
import com.example.luvreed.application.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
@Slf4j
@RequestMapping("/api/signup")
public class SignupController {

    private final SignupService signUpService;
    private final UserService memberService;

    @PostMapping("/submit")//회원가입 OK
    public ResponseEntity<SignRequestDto> signUp(@RequestBody SignRequestDto request) throws Exception {
        try {
            SignRequestDto registeredUser = signUpService.register(request);
            return ResponseEntity.ok(registeredUser);
        } catch (IllegalArgumentException e) {
            log.error("중복된 이메일로 인한 회원 가입 실패", e);
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        } catch (Exception e) {
            log.error("회원 가입 중 오류 발생", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verifyEmail(@RequestBody LoginRequestDto loginRequestDto) {
        if (memberService.isEmailDuplicate(loginRequestDto.getEmail())) {
            return ResponseEntity.ok(loginRequestDto);
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }
}
