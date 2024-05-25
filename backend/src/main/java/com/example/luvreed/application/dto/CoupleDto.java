package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Pet;
import com.example.luvreed.application.entity.Chatroom;
import com.example.luvreed.application.entity.Couple;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.util.Date;

public class CoupleDto {
    private static final String memoDatePattern = "yyyy-MM-dd";
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
        private Long id;
        private Chatroom chatroom;
        private Pet pet;
        private Date dday;
    }

    public Couple toEntity(CoupleDto.Request request) {
        Couple couple = Couple.builder()
                .id(request.getId())
                .chatroom(request.getChatroom())
                //.charactar(request.getCharactar())
                .dday(request.getDday())
                .build();
        return couple;
    }

    @Getter
    public static class Response {
        private final Long id;
        private final Chatroom chatroom;
        //private final Charactar charactar;
        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private final Date dday;

        public Response(Couple couple) {
            this.id = couple.getId();
            this.chatroom = couple.getChatroom();
            //this.charactar = couple.getCharactar();
            this.dday = couple.getDday();
        }

        public static CoupleDto.Response fromEntity(Couple couple) {
            return new CoupleDto.Response(couple);
        }
    }
}
