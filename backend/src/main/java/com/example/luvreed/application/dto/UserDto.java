package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.Role;
import com.example.luvreed.application.entity.User;
import lombok.*;
import java.io.Serializable;
import java.util.List;
import java.util.stream.Collectors;

/**
 * request, response DTO 클래스를 하나로 묶어 InnerStaticClass로 한 번에 관리
 */

@AllArgsConstructor
@Data
public class UserDto {

    //private final User user;

    private Long id;
    private Couple couple;
    private String email;
    private String name;
    private String password;
    private Role role;
    private String code;

    public UserDto(User user) {
        this.id = user.getId();
        this.couple = user.getCouple();
        this.password = user.getPassword();
        this.name = user.getName();
        this.email = user.getEmail();
        this.role = user.getRole();
        this.code = user.getCode();
    }

    /** 회원 Service 요청(Request) DTO 클래스 */
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Builder
    public static class Request {

        private Long id;
        private Couple couple;
        private String email;
        private String name;
        private String password;
        private Role role;
        private String code;

        /* DTO -> Entity */
        public User toEntity() {
            User user = User.builder()
                    .id(id)
                    .couple(couple)
                    .password(password)
                    .name(name)
                    .email(email)
                    .role(role)
                    .code(code)
                    .build();
            return user;
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
        private final Couple couple;
        private final String email;
        private final String name;
        private final String password;
        private final Role role;

        /* Entity -> dto */
        public Response(User user) {
            this.id = user.getId();
            this.couple = user.getCouple();
            this.password = user.getPassword();
            this.email = user.getEmail();
            this.name = user.getName();
            this.role = user.getRole();
        }
        public static Response fromEntity(User user) {
            return new Response(user);
        }
    }

    public static List<Response> fromEntityList(List<User> userList) {
        return userList.stream()
                .map(Response::fromEntity)
                .collect(Collectors.toList());
    }
}
