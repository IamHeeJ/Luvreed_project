package com.example.luvreed.application.dto;


import com.example.luvreed.application.entity.Chatroom;
import com.example.luvreed.application.entity.Couple;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.Date;

@Getter
public class ChatroomDto {
    @NotNull(message = "There is no chatroomid")
    private Long chatroomId;

    @NotNull(message = "There is no Couple")
    private Couple couple;

    @Getter
    public static class Response {
        private final Long chatroomId;
        private final Couple couple;

        public Response(Chatroom chatroom) {
            this.chatroomId = chatroom.getId();
            this.couple = chatroom.getCouple();
        }

        public static ChatroomDto.Response fromEntity(Chatroom chatroom) {
            return new ChatroomDto.Response(chatroom);
        }
    }
}

