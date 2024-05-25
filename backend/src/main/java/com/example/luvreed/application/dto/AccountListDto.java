package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Role;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class AccountListDto {
    @Getter
    @Setter
    @NoArgsConstructor
    public static class Response { //이름, 이메일, role // 이름, 이메일, role
        private String userName;
        private String userEmail;
        private Role role;
        private String loverName;
        private String loverEmail;
        private Role loverRole;

//        public Response(Long userId, String userNickName, Long loverId, String loverNickname) {
//            this.userId = userId;
//            this.userNickName = userNickName;
//            this.loverId = loverId;
//            this.loverNickname = loverNickname;
//        }
//
//        // Optional: fromEntity 메서드 추가
//        public static HomeCoupleProfileDto.Response fromEntity(ProfileDto.Response userProfile, ProfileDto.Response loverProfile) {
//            if (userProfile == null || loverProfile == null) {
//                return null;
//            }
//            return new HomeCoupleProfileDto.Response(
//                    loverProfile.getUserId(), loverProfile.getNickname(),
//                    userProfile.getUserId(), userProfile.getNickname()
//            );
//        }
    }
}
