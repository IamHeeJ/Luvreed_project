package com.example.luvreed.application.controller;

import com.example.luvreed.application.document.ChatHistory;
import com.example.luvreed.application.dto.ChartDto;
import com.example.luvreed.application.dto.GalleryDto;
import com.example.luvreed.application.dto.ProfileDto;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.Profile;
import com.example.luvreed.application.entity.User;
import com.example.luvreed.application.service.*;
import com.example.luvreed.security.MyUserDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@RequiredArgsConstructor
@Slf4j
@RestController
@RequestMapping("/api")
public class GalleryController {
    private final GalleryService galleryService;
    private final ProfileService profileService;
    private final UserService userService;
    private final StorageService storageService;
    private final ChatService chatService;
    private final FileDeleteService fileDeleteService;

    private final String rootPath = "C:\\Final_project\\image_storage";
    @PostMapping("/saveimage") //profile 로컬 스토리지에 이미지 저장 및 MariaDB profile table에 저장
    public ResponseEntity<GalleryDto.Response> saveImage(@RequestPart("image") MultipartFile file,
                                                         @AuthenticationPrincipal MyUserDetails myUserDetails) throws Exception {
        try {
            if (myUserDetails != null) {
                Couple couple = myUserDetails.getCouple();
                User user = myUserDetails.getUser();
                Long loverId = userService.getLover(user.getId(), couple.getId());
                GalleryDto.Request requestDto = new GalleryDto.Request(file);
                //profile table에 접근해 profile.image_path에 있는 실제 이미지파일 삭제
                String originProfilePath = profileService.getProfile(loverId).getImagePath(); //기존 프로필 이미지 경로
                storageService.deleteFile(originProfilePath);
                GalleryDto.Response response = galleryService.saveImage(requestDto, couple, user);
                profileService.putImagePathInProfile(loverId, response.getImagePath()); //전송받은 사진경로를 profile imagePath에 저장
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while saving image", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/savechatimage")
    public ResponseEntity<GalleryDto.Response> saveChatImage(@RequestPart("image") MultipartFile file,
                                                             @AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Couple couple = myUserDetails.getCouple();
                User user = myUserDetails.getUser();
                GalleryDto.Response response = galleryService.saveChatImage(file, couple, user);
                if (response != null) {
                    log.info("savechatimage response@@: {}", response);
                    return new ResponseEntity<>(response, HttpStatus.OK);
                } else {
                    return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
                }
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while saving image", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getbroadcastingimage")
    public ResponseEntity<byte[]> getBroadCastingImageByUser(@AuthenticationPrincipal MyUserDetails myUserDetails, @RequestParam String imageUrl) {
        try {
            if (myUserDetails != null) {
                Resource imageResource = storageService.loadAsResource(imageUrl);

                if (imageResource != null) {
                    byte[] imageBytes = imageResource.getInputStream().readAllBytes();
                    return ResponseEntity.ok()
                            .contentType(MediaType.IMAGE_JPEG) // 이미지 타입에 맞게 설정
                            .body(imageBytes);
                } else {
                    log.info("Image not found.");
                    return ResponseEntity.notFound().build();
                }
            } else {
                log.info("User not authenticated.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (Exception e) {
            log.error("Error while fetching image", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

//    @GetMapping("/getmongodbimages") //이미지 잘나오긴하는데 삭제 다운이 안됨.
//    public ResponseEntity<List<Map<String, Object>>> getMongoDBImagesByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
//                                                                            @RequestParam Long chatroomId) {
//        try {
//            if (myUserDetails != null) {
//                List<ChatHistory> chatHistories = chatService.readHistory(chatroomId);
//                List<Map<String, Object>> imageDataList = new ArrayList<>();
//
//                for (ChatHistory chatHistory : chatHistories) {
//                    if (chatHistory.getImagePath() != null) {
//                        try {
//                            Resource imageResource = storageService.loadAsResource(chatHistory.getImagePath());
//                            byte[] imageBytes = imageResource.getInputStream().readAllBytes();
//                            String imageData = Base64.getEncoder().encodeToString(imageBytes);
//
//                            Map<String, Object> imageInfo = new HashMap<>();
//                            imageInfo.put("imageData", imageData);
//                            imageInfo.put("createdAt", chatHistory.getCreatedAt());
//
//                            imageDataList.add(imageInfo);
//                        } catch (FileNotFoundException e) {
//                            // 이미지 파일이 존재하지 않는 경우 건너뜁
//                            log.warn("Image file not found: {}", chatHistory.getImagePath());
//                        }
//                    }
//                }
//
//                return ResponseEntity.ok(imageDataList);
//            } else {
//                log.info("User not authenticated.");
//                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
//            }
//        } catch (Exception e) {
//            log.error("Error while fetching images", e);
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }
@GetMapping("/getmongodbimages")
public ResponseEntity<List<Map<String, Object>>> getMongoDBImagesByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                        @RequestParam Long chatroomId) {
    try {
        if (myUserDetails != null) {
            List<ChatHistory> chatHistories = chatService.readHistory(chatroomId);
            List<Map<String, Object>> imageDataList = new ArrayList<>();

            for (ChatHistory chatHistory : chatHistories) {
                if (chatHistory.getImagePath() != null) {
                    try {
                        Resource imageResource = storageService.loadAsResource(chatHistory.getImagePath());
                        byte[] imageBytes = imageResource.getInputStream().readAllBytes();
                        String imageData = Base64.getEncoder().encodeToString(imageBytes);

                        Map<String, Object> imageInfo = new HashMap<>();
                        imageInfo.put("imageData", imageData);
                        imageInfo.put("imageUrl", chatHistory.getImagePath()); // 이미지 URL 추가
                        imageInfo.put("createdAt", chatHistory.getCreatedAt());

                        imageDataList.add(imageInfo);
                    } catch (FileNotFoundException e) {
                        log.warn("Image file not found: {}", chatHistory.getImagePath());
                    }
                }
            }

            return ResponseEntity.ok(imageDataList);
        } else {
            log.info("User not authenticated.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    } catch (Exception e) {
        log.error("Error while fetching images", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}

    @GetMapping("/downloadimage")
    public ResponseEntity<byte[]> downloadImageByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                      @RequestParam String imageUrl) {
        try {
            if (myUserDetails != null) {
                Resource imageResource = storageService.loadAsResource(imageUrl);
                byte[] imageBytes = imageResource.getInputStream().readAllBytes();
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(imageBytes);
            } else {
                log.info("User not authenticated.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (Exception e) {
            log.error("Error while downloading image", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    @DeleteMapping("/deleteimage")
    public ResponseEntity<Void> deleteImageByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                  @RequestParam String imageUrl) {
        try {
            if (myUserDetails != null) {
                boolean deleted = fileDeleteService.deleteFileWithRetry(imageUrl);
                if (deleted) {
                    return ResponseEntity.ok().build();
                } else {
                    return ResponseEntity.status(HttpStatus.CONFLICT).build();
                }
            } else {
                log.info("User not authenticated.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
        } catch (Exception e) {
            log.error("Error while deleting image", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

//    @GetMapping("/downloadimage")
//    public ResponseEntity<byte[]> downloadImageByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
//                                                      @RequestParam Long chatroomId,
//                                                      @RequestParam int index) {
//        try {
//            if (myUserDetails != null) {
//                List<ChatHistory> chatHistories = chatService.readHistory(chatroomId);
//                if (index >= 0 && index < chatHistories.size()) {
//                    ChatHistory chatHistory = chatHistories.get(index);
//                    if (chatHistory.getImagePath() != null) {
//                        Resource imageResource = storageService.loadAsResource(chatHistory.getImagePath());
//                        byte[] imageBytes = imageResource.getInputStream().readAllBytes();
//                        return ResponseEntity.ok()
//                                .contentType(MediaType.IMAGE_JPEG)
//                                .body(imageBytes);
//                    } else {
//                        log.info("Image not found at index: {}", index);
//                        return ResponseEntity.notFound().build();
//                    }
//                } else {
//                    log.info("Invalid index: {}", index);
//                    return ResponseEntity.badRequest().build();
//                }
//            } else {
//                log.info("User not authenticated.");
//                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
//            }
//        } catch (Exception e) {
//            log.error("Error while downloading image", e);
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }

//    @DeleteMapping("/deleteimage")
//    public ResponseEntity<Void> deleteImageByUser(@AuthenticationPrincipal MyUserDetails myUserDetails,
//                                                  @RequestParam Long chatroomId,
//                                                  @RequestParam int index) {
//        try {
//            if (myUserDetails != null) {
//                List<ChatHistory> chatHistories = chatService.readHistory(chatroomId);
//                if (index >= 0 && index < chatHistories.size()) {
//                    ChatHistory chatHistory = chatHistories.get(index);
//                    if (chatHistory.getImagePath() != null) {
//                        boolean deleted = fileDeleteService.deleteFileWithRetry(chatHistory.getImagePath());
//                        if (deleted) {
//                            chatHistory.setImagePath(null);
//                            chatService.saveHistory(chatHistory);
//                            return ResponseEntity.ok().build();
//                        } else {
//                            return ResponseEntity.status(HttpStatus.CONFLICT).build();
//                        }
//                    } else {
//                        log.info("Image not found at index: {}", index);
//                        return ResponseEntity.notFound().build();
//                    }
//                } else {
//                    log.info("Invalid index: {}", index);
//                    return ResponseEntity.badRequest().build();
//                }
//            } else {
//                log.info("User not authenticated.");
//                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
//            }
//        } catch (Exception e) {
//            log.error("Error while deleting image", e);
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
//        }
//    }
}
