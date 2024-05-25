package com.example.luvreed.application.dto;

import com.example.luvreed.application.document.ChatHistory;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.util.Date;

public class ChatDto {
    private static final String memoDatePattern = "yyyy-MM-dd HH:mm:ss";
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Getter
    public static class ChatRequest {
        private String id;
        private Long userId;
        private Long coupleId;
        private Long chatroomId;
        private String text;
        private String emotion;
        private String checked;
        private String imagePath;
        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private Date createdAt;

        public static ChatRequest ToRequest(Long userId, Long coupleId, Long chatroomId, String text,
                                            String emotion, String checked, String imagePath) {
            ChatRequest request = new ChatRequest();

            request.setUserId(userId);
            request.setCoupleId(coupleId);
            request.setChatroomId(chatroomId);
            request.setText(text);
            request.setEmotion(emotion);
            request.setChecked(checked);
            request.setImagePath(imagePath);
            request.setCreatedAt(null);
            return request;
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    @Getter
    public static class ChatResponse {
        private String id;
        private Long userId;
        private Long coupleId;
        private Long chatroomId;
        private String text;
        private String emotion;
        private String checked;
        private String imagePath;
        private byte[] imageBytes;
        private Long petId;
        private Long petCollection;
        private int PetExperience;
        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private Date createdAt;

        public static ChatResponse ToResponse(ChatHistory chatHistory) {
            ChatResponse response = new ChatResponse();
            response.setId(chatHistory.getId());
            response.setUserId(chatHistory.getUserId());
            response.setCoupleId(chatHistory.getCoupleId());
            response.setChatroomId(chatHistory.getChatroomId());
            response.setText(chatHistory.getText());
            response.setEmotion(chatHistory.getEmotion());
            response.setChecked(chatHistory.getChecked());
            response.setImagePath(chatHistory.getImagePath());
            response.setCreatedAt(chatHistory.getCreatedAt());
            return response;
        }
    }
}
