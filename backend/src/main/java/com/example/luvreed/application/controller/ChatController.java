package com.example.luvreed.application.controller;

import com.example.luvreed.application.document.ChatHistory;
import com.example.luvreed.application.dto.ChatDto;
import com.example.luvreed.application.entity.Collection;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.Pet;
import com.example.luvreed.application.service.*;
import com.example.luvreed.jwt.JwtProvider;
import com.example.luvreed.security.MyUserDetails;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.util.http.fileupload.FileItem;
import org.apache.tomcat.util.http.fileupload.IOUtils;
import org.apache.tomcat.util.http.fileupload.disk.DiskFileItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.MessageDeliveryException;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import org.springframework.web.socket.messaging.SessionSubscribeEvent;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Principal;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Controller
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService; //몽고디비에 채팅내용을 저장.
    private final AiService aiService;
    private final ChartService chartService;
    private final JwtProvider jwtUtils;
    private final PetService petService;
    private final CollectionService collectionService;
    private final StorageService storageService;
    private final SimpMessagingTemplate template;
    private final String noticeDestination = "/sub/notice";
    private final HashMap<String, String> simpSessionIdMap = new HashMap<>();   // stomp에 CONNECT한 유저 정보

    @MessageMapping("/chat/{chatroomId}")
    @SendTo("/sub/chat/{chatroomId}")
    public ChatDto.ChatResponse broadcasting(final String messageJson,
                                             StompHeaderAccessor accessor,
                                             @DestinationVariable(value = "chatroomId") final Long chatroomId) {
        String accessToken = jwtUtils.extractJwt(accessor);
        log.info("Extracted token: {}", accessToken);

        try {
            if (accessToken != null) {
                UserDetails userDetails = (UserDetails) jwtUtils.getAuthentication(accessToken).getPrincipal();
                if (userDetails instanceof MyUserDetails) {
                    MyUserDetails myUserDetails = (MyUserDetails) userDetails;

                    Long userId = myUserDetails.getUserId();
                    Couple couple = myUserDetails.getCouple();
                    Long coupleId = myUserDetails.getCouple().getId();
                    Pet updatedPet = null;

                    ChatDto.ChatRequest request;
                    try {
                        ObjectMapper objectMapper = new ObjectMapper();
                        Map<String, Object> message = objectMapper.readValue(messageJson, new TypeReference<Map<String, Object>>() {
                        });

                        String text = (String) message.get("text");
                        String imageUrl = (String) message.get("imageUrl");

                        if (imageUrl != null && !imageUrl.isEmpty()) {
                            request = ChatDto.ChatRequest.ToRequest(userId, coupleId, chatroomId, null, null, "1", imageUrl);
                            log.info("{}", request);

                            // 이미지 바이트 데이터를 응답에 포함하여 브로드캐스팅
                            ChatDto.ChatResponse response = chatService.recordHistory(chatroomId, request);
                            //response.setImageBytes(imageBytes);
                            return response;
                        } else {
                            // 텍스트 메시지인 경우
                            if (text != null && !text.isEmpty()) {
                                String emotion = aiService.getEmotion(text);
                                log.info("current emotion : {}", emotion);
                                if (emotion.equals("happy")) {
                                    petService.updatePetExByCouple(coupleId);
                                    log.info("{} Pet ex +2.", coupleId);
                                    //coupleId로 selection true, 경험치 몇인지 조회, 100, 250, 450 700 1000 이면 collectionId update
                                    Pet pet = petService.findPetByCouple(couple).get();
                                    int petEx = pet.getExperience();
                                    if (petEx == 100 || petEx == 250 || petEx == 450 ||
                                            petEx == 700 || petEx == 1000) {
                                        Collection originCollection = pet.getCollection(); //ex. 12 > 13
                                        Collection newCollection = collectionService.getCollection(originCollection);
                                        updatedPet = petService.updatePetCollection(couple, originCollection, newCollection);
                                        log.info("PetId: {}, coupleId: {}, collection: {}, experience: {}",
                                                updatedPet.getId(), updatedPet.getCouple(), updatedPet.getCollection(), updatedPet.getExperience());
                                    }
                                }
                                chartService.updateEmotionByuserId(emotion, userId, coupleId);
                                request = ChatDto.ChatRequest.ToRequest(userId, coupleId, chatroomId, text, emotion, "1", null);
                                log.info("{}", request);
                            } else {
                                // 텍스트 메시지가 없는 경우 기본 감정 상태로 설정
                                request = ChatDto.ChatRequest.ToRequest(userId, coupleId, chatroomId, null, null, "1", null);
                                log.info("{}", request);
                            }
                        }
                    } catch (JsonProcessingException e) {
                        log.error("Error while parsing message JSON");
                        return null;
                    }

                    if (userId != null && coupleId != null) {
                        ChatDto.ChatResponse response = chatService.recordHistory(chatroomId, request);
                        if (updatedPet != null) {
                            response.setPetId(updatedPet.getId());
                            response.setPetCollection(updatedPet.getCollection().getId());
                            response.setPetExperience(updatedPet.getExperience());
                        } else {
                            Pet pet = petService.findPetByCouple(couple).get();
                            response.setPetId(pet.getId());
                            response.setPetCollection(pet.getCollection().getId());
                            response.setPetExperience(pet.getExperience());
                        }
                        if (response != null) {
                            return response;
                        } else {
                            log.error("Failed to record chat history.");
                        }
                    } else {
                        log.error("One of the required values is null. userId: {}, coupleId: {}", userId, coupleId);
                    }
                } else {
                    log.error("Invalid user details.");
                }
            } else {
                log.info("Token not provided.");
            }
        } catch (Exception e) {
            log.error("Error while processing chat message", e);
        }
        return null;
    }

//    @GetMapping("/api/chat/{chatroomId}/history") //전체 채팅내역
//    public ResponseEntity<List<ChatDto.ChatResponse>> getChatHistory(@PathVariable Long chatroomId) {
//        List<ChatHistory> chatHistory = chatService.readHistory(chatroomId);
//        List<ChatDto.ChatResponse> response = chatHistory.stream()
//                .map(history -> {
//                    ChatDto.ChatResponse chatResponse = ChatDto.ChatResponse.ToResponse(history);
//                    if (history.getImagePath() != null) {
//                        // imagePath가 있는 경우 이미지 파일을 읽어서 바이트 배열로 변환
//                        try {
//                            byte[] imageBytes = Files.readAllBytes(Paths.get(history.getImagePath()));
//                            chatResponse.setImageBytes(imageBytes);
//                        } catch (IOException e) {
//                            // 이미지 파일 읽기 실패 시 에러 처리
//                            e.printStackTrace();
//                        }
//                    }
//                    return chatResponse;
//                })
//                .collect(Collectors.toList());
//        return ResponseEntity.ok(response);
//    }

    @GetMapping("/api/chat/{chatroomId}/history")
    public ResponseEntity<List<ChatDto.ChatResponse>> getPagingChatHistory(
            @PathVariable Long chatroomId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        List<ChatHistory> chatHistory = chatService.readPagingHistory(chatroomId, pageable);

        List<ChatDto.ChatResponse> response = chatHistory.stream()
                .map(history -> {
                    ChatDto.ChatResponse chatResponse = ChatDto.ChatResponse.ToResponse(history);
                    if (history.getImagePath() != null) {
                        // imagePath가 있는 경우 이미지 파일을 읽어서 바이트 배열로 변환
                        try {
                            byte[] imageBytes = Files.readAllBytes(Paths.get(history.getImagePath()));
                            chatResponse.setImageBytes(imageBytes);
                        } catch (IOException e) {
                            // 이미지 파일 읽기 실패 시 에러 처리
                            e.printStackTrace();
                        }
                    }
                    return chatResponse;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @EventListener
    public void handleSessionConnected(SessionConnectedEvent event) {
        String simpSessionId = (String) event.getMessage().getHeaders().get("simpSessionId");

        if (event.getUser() != null) {
            Principal user = event.getUser();
            if (user != null) {
                try {
                    String username = user.getName();
                    simpSessionIdMap.put(simpSessionId, username);
                } catch (Exception e) {
                    throw new MessageDeliveryException("인증 정보가 올바르지 않습니다. 다시 로그인 후 이용해주세요.");
                }
            }
        }
    }

    @EventListener
    public void handleSessionSubscribe(SessionSubscribeEvent event) {
        String destination = (String) event.getMessage().getHeaders().get("simpDestination");
        assert destination != null;
        if (destination.equals(noticeDestination)) {
            template.convertAndSend(noticeDestination, simpSessionIdMap.values());
        }
    }

    @EventListener
    public void handleSessionDisconnect(SessionDisconnectEvent event) {
        String simpSessionId = (String) event.getMessage().getHeaders().get("simpSessionId");
        simpSessionIdMap.remove(simpSessionId);
        template.convertAndSend(noticeDestination, simpSessionIdMap.values());
    }

//    @GetMapping("/api/chat/{chatroomId}/history") //메세지 채팅내역만 가능한코드.
//    public ResponseEntity<List<ChatDto.ChatResponse>> getChatHistory(@PathVariable Long chatroomId) {
//        List<ChatHistory> chatHistory = chatService.readHistory(chatroomId);
//        List<ChatDto.ChatResponse> response = chatHistory.stream()
//                .map(ChatDto.ChatResponse::ToResponse)
//                .collect(Collectors.toList());
//        return ResponseEntity.ok(response);
//    }


//    @MessageMapping("info")
//    @SendToUser("/queue/info")
//    public String info(String message, SimpMessageHeaderAccessor messageHeaderAccessor) {
//        User talker = messageHeaderAccessor.getSessionAttributes().get(SESSION).get(USER_SESSION_KEY);
//        return message;
//    }
//
//    @MessageMapping("chat")
//    @SendTo("/topic/message")
//    public String chat(String message, SimpMessageHeaderAccessor messageHeaderAccessor) {
//        User talker = messageHeaderAccessor.getSessionAttributes().get(SESSION).get(USER_SESSION_KEY);
//        if(talker == null) throw new UnAuthenticationException("로그인한 사용자만 채팅에 참여할 수 있습니다.");
//        return message;
//    }
//
//    @MessageMapping("bye")
//    @SendTo("/topic/bye")
//    public User bye(String message) {
//        User talker = messageHeaderAccessor.getSessionAttributes().get(SESSION).get(USER_SESSION_KEY);
//        return talker;
//    }
}
