package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.*;
import com.example.luvreed.application.service.*;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.List;


@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api")
@RestController
public class AccountApiController {
    private final UserService userService;
    private final CoupleService coupleService;
    private final ChatService chatService;

    @GetMapping("/web/admin/accountlist")
    public ResponseEntity<List<AccountUserDto.Response>> getUserList(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            List<AccountUserDto.Response> userList = userService.findAccountAll();
            return new ResponseEntity<>(userList, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error while fetching userList", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    @GetMapping("/web/admin/deletecoupleaccount")
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public ResponseEntity<List<UserDto.Response>> deleteCoupleAccountByAdmin(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                             @RequestParam Long userId,
                                                                             @RequestParam Long loverId) {
        try {
            UserDto.Response userDto = userService.getUser(userId);
            UserDto.Response loverDto = userService.getUser(loverId);
            Long coupleId = userDto.getCouple().getId();

            if (!coupleService.existsById(coupleId)) {
                throw new IllegalStateException("Couple not found with id: " + coupleId);
            }

            // User 레코드 삭제
            userService.deleteUser(userId);
            userService.deleteUser(loverId);

            // User 삭제 시 CASCADE로 인해 자동으로 삭제되는 엔티티들
            // - Chart
            // - Profile
            // - Schedule
            // - Gallery

            // Couple 레코드 삭제
            coupleService.deleteCouple(coupleId);

            // Couple 삭제 시 CASCADE로 인해 자동으로 삭제되는 엔티티들
            // - ChatRoom
            // - Pet
            // - Schedule
            // - User (이미 삭제됨)

            List<UserDto.Response> userList = new ArrayList<>();
            userList.add(userDto);
            userList.add(loverDto);
            return new ResponseEntity<>(userList, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error while dropping user", e);
            throw new RuntimeException("Failed to delete couple account");
        }
    }
//    @GetMapping("/web/admin/deletecoupleaccount")
//    public ResponseEntity<List<UserDto.Response>> deleteCoupleAccountByAdmin(@AuthenticationPrincipal MyUserDetails myUserDetails,
//                                                                             @RequestParam Long userId,
//                                                                             @RequestParam Long loverId) {
//        try {
//            UserDto.Response userDto = userService.getUser(userId);
//            UserDto.Response loverDto = userService.getUser(loverId);
//
//            userService.deleteUser(userId);
//            userService.deleteUser(loverId);
//            Long coupleId = userDto.getCouple().getId();
//            coupleService.deleteCouple(coupleId);
//            chatService.deleteByCoupleId(coupleId);
//
//            List<UserDto.Response> userList = new ArrayList<>();
//            userList.add(userDto);
//            userList.add(loverDto);
//
//            return new ResponseEntity<>(userList, HttpStatus.OK);
//        } catch (Exception e) {
//            log.error("Error while dropping user", e);
//            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//    }

    @GetMapping("/web/admin/deletesoloaccount")
    public ResponseEntity<List<UserDto.Response>> deleteSoloAccountByAdmin(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                       @RequestParam Long userId) {
        try {
            UserDto.Response userDto = userService.getUser(userId);

            userService.deleteUser(userId);

            List<UserDto.Response> userList = new ArrayList<>();
            userList.add(userDto);

            return new ResponseEntity<>(userList, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error while dropping user", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/deleteaccount")//ok
    public ResponseEntity<List<UserDto.Response>> deleteAccountByUser(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            Long userId = myUserDetails.getUserId();
            Long coupleId = myUserDetails.getCouple().getId();
            Long loverId = userService.getLover(userId, coupleId);

            UserDto.Response userDto = userService.getUser(userId);
            UserDto.Response loverDto = userService.getUser(loverId);

            userService.deleteUser(userId);
            userService.deleteUser(loverId);
            coupleService.deleteCouple(coupleId);
            chatService.deleteByCoupleId(coupleId);

            List<UserDto.Response> userList = new ArrayList<>();
            userList.add(userDto);
            userList.add(loverDto);

            return new ResponseEntity<>(userList, HttpStatus.OK);
        } catch (Exception e) {
            log.error("Error while dropping User", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

//
//    @GetMapping("/password")
//    public ResponseEntity<UserDto.Response> updatePassword(@AuthenticationPrincipal MyUserDetails myUserDetails) {
//        try {
//            if (myUserDetails!=null) {
//                Long userId = myUserDetails.getUserId();
//                UserDto.Response response = userService.getUser(userId);
//                return ResponseEntity.ok(response);
//            } else {
//                log.info("User not authenticated.");
//                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
//            }
//        } catch (Exception e) {
//            log.error("Error while fetching username", e);
//            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//    }
}
