package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.CoupleDto;
import com.example.luvreed.application.dto.UserDto;
import com.example.luvreed.application.entity.User;
import com.example.luvreed.application.repository.UserRepository;
import com.example.luvreed.application.service.CoupleService;
import com.example.luvreed.application.service.UserService;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.Date;

@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api")
@RestController
public class UserApiController {
    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/userinfo")//ok 설정화면에 이름, 이메일 불러오기
    public ResponseEntity<UserDto.Response> getUsernameAndEmail(@AuthenticationPrincipal MyUserDetails myUserDetails) {
            try {
                if (myUserDetails!=null) {
                    Long userId = myUserDetails.getUserId();
                    UserDto.Response response = userService.getUser(userId);
                    return ResponseEntity.ok(response);
                } else {
                    log.info("User not authenticated.");
                    return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
                }
            } catch (Exception e) {
                log.error("Error while fetching username", e);
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
    }
    @PostMapping("/passwordmatching")
    public ResponseEntity<?> getUserPasswd(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                @RequestParam String requestPassword) {
        try {
            if (myUserDetails!=null) {
                String storagePassword = myUserDetails.getPassword();
                if(passwordEncoder.matches(requestPassword, storagePassword))
                    return ResponseEntity.ok("true");
                else {
                    return ResponseEntity.ok("false");
                }
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching password", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/change/password")
    public ResponseEntity<?> putUserPassword(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                           @RequestParam String requestPassword) {
        try {
            if (myUserDetails!=null) {
                Long userId = myUserDetails.getUserId();
                userService.putChangePasswd(userId, requestPassword);
                String storagePassword = myUserDetails.getPassword();
                if(passwordEncoder.matches(requestPassword, storagePassword))
                    return ResponseEntity.ok("false");
                else {
                    return ResponseEntity.ok("true");
                }
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching password", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
