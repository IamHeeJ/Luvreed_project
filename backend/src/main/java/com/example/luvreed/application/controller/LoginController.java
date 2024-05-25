package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.LoginRequestDto;
import com.example.luvreed.application.dto.SignResponseDto;
import com.example.luvreed.application.service.LoginService;
import com.example.luvreed.jwt.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class LoginController {
    private final LoginService loginService;
    private final JwtProvider jwtProvider;
    private final HashMap<String, String> simpSessionIdMap = new HashMap<>();   // stomp에 CONNECT한 유저 정보

    @PostMapping("/login")
    public ResponseEntity<SignResponseDto> signIn(@RequestBody LoginRequestDto requestDto) throws Exception {
        return new ResponseEntity<>(loginService.ptectLogin(requestDto), HttpStatus.OK);
    }

    @PostMapping("/web/login")
    public ResponseEntity<SignResponseDto> signInWeb(@RequestBody LoginRequestDto requestDto) throws Exception {
        return new ResponseEntity<>(loginService.webLogin(requestDto), HttpStatus.OK);
    }

    @PostMapping("/validate-token")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            if (jwtProvider.validateAccessToken(authorizationHeader)) {
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }

    @Autowired
    private SimpMessageSendingOperations messagingTemplate;

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@RequestHeader("Authorization") String authorizationHeader) {
        try {
            // 액세스 토큰 검증
            if (jwtProvider.validateAccessToken(authorizationHeader)) {
                // 현재 사용자의 세션 ID 가져오기
                String sessionId = jwtProvider.getSessionIdFromToken(authorizationHeader);

                // 세션 종료 처리
//                if (simpSessionIdMap.containsKey(sessionId)) {
//                    simpSessionIdMap.remove(sessionId);
//                }
                simpSessionIdMap.remove(sessionId);
                // 세션 종료 메시지 전송
                messagingTemplate.convertAndSend("/sub/notice", sessionId);

                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
}
