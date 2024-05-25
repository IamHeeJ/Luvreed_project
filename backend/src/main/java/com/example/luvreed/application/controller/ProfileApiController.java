package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.*;
import com.example.luvreed.application.service.CoupleService;
import com.example.luvreed.application.service.ProfileService;
import com.example.luvreed.application.service.StorageService;
import com.example.luvreed.application.service.UserService;
import com.example.luvreed.security.MyUserDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.*;

@RequiredArgsConstructor
@Slf4j
@RestController
@RequestMapping("/api")
public class ProfileApiController {
    private final UserService userService;
    private final CoupleService coupleService;
    private final ProfileService profileService;
    private final StorageService storageService;

    @GetMapping("/getcoupleprofile")
    public ResponseEntity<byte[]> getCoupleProfileByUser(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Long loverId = userService.getLover(userId, coupleId);

                log.info("Couple ID: {}, user ID: {}, Lover ID: {}", coupleId, userId, loverId);

                ProfileDto.Response userProfile = profileService.getProfile(loverId);
                ProfileDto.Response loverProfile = profileService.getProfile(userId);

                if (userProfile != null && loverProfile != null) {
                    // 이미지 파일 로드 (null 값 허용)
                    Resource userImageResource = null;
                    Resource loverImageResource = null;
                    try {
                        if (userProfile.getImagePath() != null) {
                            userImageResource = storageService.loadAsResource(userProfile.getImagePath());
                        }
                        if (loverProfile.getImagePath() != null) {
                            loverImageResource = storageService.loadAsResource(loverProfile.getImagePath());
                        }
                    } catch (Exception e) {
                        log.warn("Failed to load image resources", e);
                    }

                    // 프로필 정보와 이미지를 Map에 저장
                    Map<String, Object> responseData = new HashMap<>();
                    responseData.put("userId", userProfile.getUserId());
                    responseData.put("userNickName", loverProfile.getNickname());
                    responseData.put("loverId", loverProfile.getUserId());
                    responseData.put("loverNickname", userProfile.getNickname());

                    // 이미지 파일이 있는 경우에만 이미지 처리
                    if (userImageResource != null) {
                        byte[] userImageBytes = userImageResource.getInputStream().readAllBytes();
                        String userImageBase64 = Base64.getEncoder().encodeToString(userImageBytes);
                        responseData.put("userImage", userImageBase64);
                    }
                    if (loverImageResource != null) {
                        byte[] loverImageBytes = loverImageResource.getInputStream().readAllBytes();
                        String loverImageBase64 = Base64.getEncoder().encodeToString(loverImageBytes);
                        responseData.put("loverImage", loverImageBase64);
                    }

                    // Map을 JSON 문자열로 변환
                    ObjectMapper objectMapper = new ObjectMapper();
                    String jsonResponse = objectMapper.writeValueAsString(responseData);

                    // JSON 문자열을 바이트 배열로 변환하여 응답
                    return ResponseEntity.ok()
                            .contentType(MediaType.APPLICATION_JSON)
                            .body(jsonResponse.getBytes());
                } else {
                    log.info("Profile not found.");
                    return ResponseEntity.notFound().build();
                }
            } else {
                log.info("User not authenticated.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (NoSuchElementException e) {
            log.error("Profile not found", e);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error while fetching profile", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

//    @GetMapping("/getcoupleprofile")
//    public ResponseEntity<byte[]> getCoupleProfileByUser(@AuthenticationPrincipal MyUserDetails myUserDetails) {
//        try {
//            if (myUserDetails != null) {
//                Long userId = myUserDetails.getUserId();
//                Long coupleId = myUserDetails.getCouple().getId();
//                Long loverId = userService.getLover(userId, coupleId);
//
//                log.info("Couple ID: {}, user ID: {}, Lover ID: {}", coupleId, userId, loverId);
//
//                ProfileDto.Response userProfile = profileService.getProfile(loverId);
//                ProfileDto.Response loverProfile = profileService.getProfile(userId);
//
//                if (userProfile != null && loverProfile != null) {
//                    // 이미지 파일 로드
//                    Resource userImageResource = storageService.loadAsResource(userProfile.getImagePath());
//                    Resource loverImageResource = storageService.loadAsResource(loverProfile.getImagePath());
//
//                    // 이미지 파일을 바이트 배열로 변환
//                    byte[] userImageBytes = userImageResource.getInputStream().readAllBytes();
//                    byte[] loverImageBytes = loverImageResource.getInputStream().readAllBytes();
//
//                    String userImageBase64 = Base64.getEncoder().encodeToString(userImageBytes);
//                    String loverImageBase64 = Base64.getEncoder().encodeToString(loverImageBytes);
//
//                    // 프로필 정보와 이미지를 Map에 저장
//                    Map<String, Object> responseData = new HashMap<>();
//                    responseData.put("userId", userProfile.getUserId());
//                    responseData.put("userNickName", userProfile.getNickname());
//                    responseData.put("loverId", loverProfile.getUserId());
//                    responseData.put("loverNickname", loverProfile.getNickname());
//                    responseData.put("userImage", userImageBase64);
//                    responseData.put("loverImage", loverImageBase64);
//
//                    // Map을 JSON 문자열로 변환
//                    ObjectMapper objectMapper = new ObjectMapper();
//                    String jsonResponse = objectMapper.writeValueAsString(responseData);
//
//                    // JSON 문자열을 바이트 배열로 변환하여 응답
//                    return ResponseEntity.ok()
//                            .contentType(MediaType.APPLICATION_JSON)
//                            .body(jsonResponse.getBytes());
//                } else {
//                    log.info("Profile not found.");
//                    return ResponseEntity.notFound().build();
//                }
//            } else {
//                log.info("User not authenticated.");
//                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
//            }
//        } catch (NoSuchElementException e) {
//            log.error("Profile not found", e);
//            return ResponseEntity.notFound().build();
//        } catch (Exception e) {
//            log.error("Error while fetching profile", e);
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }

    @GetMapping("/getloverprofile")
    public ResponseEntity<byte[]> getLoverProfileByUser(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Long loverId = userService.getLover(userId, coupleId);

                log.info("Couple ID: {}, user ID: {}, Lover ID: {}", coupleId, userId, loverId);

                ProfileDto.Response loverProfile = profileService.getProfile(loverId);

                if (loverProfile != null) {
                    Resource loverImageResource = null;
                    try {
                        // 이미지 파일 로드
                        loverImageResource = storageService.loadAsResource(loverProfile.getImagePath());
                    } catch (Exception e) {
                        log.warn("Failed to load image resources", e);
                    }

                    // 프로필 정보와 이미지를 Map에 저장
                    Map<String, Object> responseData = new HashMap<>();
                    responseData.put("loverId", loverProfile.getUserId());
                    responseData.put("loverNickname", loverProfile.getNickname());

                    // 이미지 파일을 바이트 배열로 변환
                    if (loverImageResource != null) {
                        byte[] loverImageBytes = loverImageResource.getInputStream().readAllBytes();
                        String loverImageBase64 = Base64.getEncoder().encodeToString(loverImageBytes);
                        responseData.put("loverImage", loverImageBase64);
                    }

                    // Map을 JSON 문자열로 변환
                    ObjectMapper objectMapper = new ObjectMapper();
                    String jsonResponse = objectMapper.writeValueAsString(responseData);

                    // JSON 문자열을 바이트 배열로 변환하여 응답
                    return ResponseEntity.ok()
                            .contentType(MediaType.APPLICATION_JSON)
                            .body(jsonResponse.getBytes());
                } else {
                    log.info("Profile not found.");
                    return ResponseEntity.notFound().build();
                }
            } else {
                log.info("User not authenticated.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (NoSuchElementException e) {
            log.error("Profile not found", e);
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.error("Error while fetching profile", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
//    @GetMapping("/getcoupleprofile") //두 명의 유저아이디와 유저닉네임만 가져옴.
//    public ResponseEntity<HomeCoupleProfileDto.Response> getCoupleProfileByUser(@AuthenticationPrincipal MyUserDetails myUserDetails) {
//        try {
//            if (myUserDetails != null) {
//                Long userId = myUserDetails.getUserId();
//                Long coupleId = myUserDetails.getCouple().getId();
//                Long loverId = userService.getLover(userId, coupleId);
//
//                // 수정된 부분
//                log.info("Couple ID: {}, user ID: {}, Lover ID: {}", coupleId, userId, loverId);
//
//                ProfileDto.Response userProfile = profileService.getProfile(loverId);
//                ProfileDto.Response loverProfile = profileService.getProfile(userId);
//
//                if (userProfile != null && loverProfile != null) {
//                    HomeCoupleProfileDto.Response response = HomeCoupleProfileDto.Response.fromEntity(userProfile, loverProfile);
//                    if (response != null) {
//                        return ResponseEntity.ok(response);
//                    } else {
//                        log.info("Profile not found.");
//                        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
//                    }
//
//                } else {
//                    log.info("Profile not found.");
//                    return new ResponseEntity<>(HttpStatus.NOT_FOUND);
//                }
//            } else {
//                log.info("User not authenticated.");
//                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
//            }
//        } catch (NoSuchElementException e) {
//            log.error("Profile not found", e);
//            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
//        } catch (Exception e) {
//            log.error("Error while fetching profile", e);
//            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
//        }
//    }

    @PostMapping("/dday")//ok 커플 매칭 후 처음 유저 본인 이름과 커플 dday 설정
    public ResponseEntity<CoupleDto.Response> postNameAndDdayByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                   @RequestParam String name,
                                                                   @RequestParam String dday) {
        try {
            if (myUserDetails!=null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Date parsedDday = new SimpleDateFormat("yyyy-MM-dd").parse(dday);
                userService.putName(userId, name);
                CoupleDto.Response response = coupleService.putDday(coupleId, parsedDday);
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

    @PostMapping("/firstprofile")//ok 커플 매칭 후 처음 유저 본인 이름과 커플 dday 설정
    public ResponseEntity<CoupleDto.Response> postNameAndDdayByUserBybody(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                          @RequestBody FirstProfileDto request) {
        try {
            if (myUserDetails!=null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Date parsedDday = new SimpleDateFormat("yyyy-MM-dd").parse(request.getDday());
                userService.putName(userId, request.getName());
                CoupleDto.Response response = coupleService.putDday(coupleId, parsedDday);
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

    @PutMapping("/nickname")
    public ResponseEntity<ProfileDto.Response> putUserNickname(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                            @RequestParam String nickname) {
        try {
            if (myUserDetails!=null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Long loverId = userService.getLover(userId, coupleId);
                profileService.updateNicknameByUserId(loverId, nickname);
                ProfileDto.Response response = profileService.getProfile(loverId);
                return ResponseEntity.ok(response);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        }catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
