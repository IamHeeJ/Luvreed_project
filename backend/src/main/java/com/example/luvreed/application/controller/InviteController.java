package com.example.luvreed.application.controller;
import com.example.luvreed.application.dto.ChartDto;
import com.example.luvreed.application.dto.ChatroomDto;
import com.example.luvreed.application.dto.UserDto;
import com.example.luvreed.application.entity.Chatroom;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.User;
import com.example.luvreed.application.repository.ChatroomRepository;
import com.example.luvreed.application.repository.CoupleRepository;
import com.example.luvreed.application.repository.UserRepository;
import com.example.luvreed.application.service.InviteService;
import com.example.luvreed.application.service.UserService;
import com.example.luvreed.security.MyUserDetails;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import javax.swing.text.html.Option;
import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import static net.sf.jsqlparser.util.validation.metadata.NamedObject.user;

@RequiredArgsConstructor
@Slf4j
@RestController
@RequestMapping("/api")
public class InviteController {
    private final Map<String, SseEmitter> sseEmitters = new ConcurrentHashMap<>();
    private final Map<String, String> inviteCodes = new ConcurrentHashMap<>();

    private final InviteService inviteService;
    private final UserRepository userRepository;
    private final CoupleRepository coupleRepository;
    private final UserService userService;
    private final ChatroomRepository chatroomRepository;
    // 초대 코드 생성 및 저장

    @GetMapping("/invitecode")
    public ResponseEntity<String> generateInviteCode(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails == null) {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            } else if (myUserDetails.isCodeExist()) {
                String originalCode = myUserDetails.getUser().getCode();
                return new ResponseEntity<>(originalCode,HttpStatus.OK);
            } else {
                Long userId = myUserDetails.getUserId();
                String inviteCode = generateInviteCode();
                userService.updateCodeByUserInNewTransaction(userId, inviteCode);
                return new ResponseEntity<>(inviteCode, HttpStatus.OK);
            }
        } catch (Exception e) {
            log.error("Error while generating invite code", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // 초대 코드 확인 및 커플 매칭
    @PostMapping("/connect")
    public ResponseEntity<Couple> connectCouple(@RequestParam("invite_code") String inviteCode, @AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null && !inviteCode.isEmpty()) {
                User matchedUser = userRepository.findByCode(inviteCode);
                String userId = myUserDetails.getUserId().toString();
                String coupleId = inviteService.createCouple(userId, matchedUser);
                Couple couple = coupleRepository.findCoupleById(Long.parseLong(coupleId)).get();
                return new ResponseEntity<>(couple, HttpStatus.OK);
            } else {

            }
        } catch (Exception e) {
            log.error("Error while generating invite code", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    @PostMapping("/connectandreturnchatroom")
    public ResponseEntity<ChatroomDto.Response> connectCoupleAndReturnChatroom(@RequestParam("invite_code") String inviteCode, @AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null && !inviteCode.isEmpty()) {
                User matchedUser = userRepository.findByCode(inviteCode);
                String userId = myUserDetails.getUserId().toString();
                String coupleId = inviteService.createCouple(userId, matchedUser);
                Couple couple = coupleRepository.findCoupleById(Long.parseLong(coupleId)).get();

                Chatroom chatroom = chatroomRepository.findAllByCouple(couple).get();
                //log.info("chatroom:{}",chatroom);
                return new ResponseEntity<>(ChatroomDto.Response.fromEntity(chatroom), HttpStatus.OK);
            } else {

            }
        } catch (Exception e) {
            log.error("Error while generating invite code", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
        return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
    }

    public String generateInviteCode() {
        return String.valueOf((int)(Math.random() * 9000) + 1000);
    }
}
