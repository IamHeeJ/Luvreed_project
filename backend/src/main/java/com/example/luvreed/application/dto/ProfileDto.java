package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.Profile;
import com.example.luvreed.application.entity.Role;
import com.example.luvreed.application.entity.User;
import lombok.*;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@AllArgsConstructor
@Data
public class ProfileDto {
    //private final User user;

    private Long id;
    private User user;
    private String nickname;
    private String imagePath;
    private Timestamp createdAt;

    public ProfileDto(Profile profile) {
        this.id = profile.getId();
        this.user = profile.getUser();
        this.nickname = profile.getNickname();
        this.imagePath = profile.getImagePath();
        this.createdAt = profile.getCreatedAt();
    }

    /** 회원 Service 요청(Request) DTO 클래스 */
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Request {

        private Long id;
        private User user;
        private String nickname;
        private String imagePath;
        private Timestamp createdAt;

        public Request(Profile profile) {
            this.id = profile.getId();
            this.user = profile.getUser();
            this.nickname = profile.getNickname();
            this.imagePath = profile.getImagePath();
            this.createdAt = profile.getCreatedAt();
        }

        /* DTO -> Entity */
        public Profile toEntity() {
            Profile profile = Profile.builder()
                    .id(id)
                    .user(user)
                    .nickname(nickname)
                    .imagePath(imagePath)
                    .createdAt(createdAt)
                    .build();
            return profile;
        }
    }

    /**
     * 인증된 사용자 정보를 세션에 저장하기 위한 클래스
     * 세션을 저장하기 위해 User 엔티티 클래스를 직접 사용하게 되면 직렬화를 해야 하는데,
     * 엔티티 클래스에 직렬화를 넣어주면 추후에 다른 엔티티와 연관관계를 맺을시
     * 직렬화 대상에 다른 엔티티까지 포함될 수 있어 성능 이슈 우려가 있기 때문에
     * 세션 저장용 Dto 클래스 생성
     * */
    @Getter
    public static class Response implements Serializable {

        private final Long id;
        private final Long userId;
        private final String nickname;
        private final String imagePath;
        private final Timestamp createdAt;

        /* Entity -> dto */
        public Response(Profile profile) {
            this.id = profile.getId();
            this.userId = profile.getUser().getId();
            this.nickname = profile.getNickname();
            this.imagePath = profile.getImagePath();
            this.createdAt = profile.getCreatedAt();
        }
        public static ProfileDto.Response fromEntity(Profile profile) {
            return new ProfileDto.Response(profile);
        }
    }

    public static List<ProfileDto.Response> fromEntityList(List<Profile> profileList) {
        return profileList.stream()
                .map(ProfileDto.Response::fromEntity)
                .collect(Collectors.toList());
    }
}
