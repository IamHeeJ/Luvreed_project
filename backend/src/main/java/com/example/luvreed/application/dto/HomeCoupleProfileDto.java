package com.example.luvreed.application.dto;
import lombok.*;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.InputStreamResource;


public class HomeCoupleProfileDto {

    @Getter
    @Setter
    @NoArgsConstructor
    public static class Response {
        private Long userId;
        private String userNickName;
        private Long loverId;
        private String loverNickname;
        private InputStreamResource userImage;
        private InputStreamResource loverImage;

        public Response(Long userId, String userNickName, Long loverId, String loverNickname, InputStreamResource userImage, InputStreamResource loverImage) {
            this.userId = userId;
            this.userNickName = userNickName;
            this.loverId = loverId;
            this.loverNickname = loverNickname;
            this.userImage = userImage;
            this.loverImage = loverImage;
        }

        public static Response fromEntity(ProfileDto.Response userProfile, ProfileDto.Response loverProfile, InputStreamResource userImage, InputStreamResource loverImage) {
            if (userProfile == null || loverProfile == null) {
                return null;
            }
            return new Response(
                    loverProfile.getUserId(), loverProfile.getNickname(),
                    userProfile.getUserId(), userProfile.getNickname(),
                    userImage, loverImage
            );
        }

        // Getters and setters
    }
}

