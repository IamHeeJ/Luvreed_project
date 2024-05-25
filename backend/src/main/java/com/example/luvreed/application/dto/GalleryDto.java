package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;

public class GalleryDto {
    private static final String memoDatePattern = "yyyy-MM-dd";
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
//        private Long id;
//        private Couple couple;
//        private User user;
//        private String imageFilename;
//        private String imagePath;
        private MultipartFile multipartFile;
    }

    public Gallery toEntity(GalleryDto.Request request) {
        Gallery gallery = Gallery.builder()
                //.id(request.getId())
//                .couple(request.getCouple())
//                .user(request.getUser())
//                .imageFilename(request.imageFilename)
//                .imagePath(request.imagePath)
                .build();
        return gallery;
    }

    @Getter
    public static class Response {
        private final Long id;
        @JsonIgnore
        private final Couple couple;
        @JsonIgnore
        private final User user;
        private final String imageFilename;
        private final String imagePath;

        public Response(Gallery gallery) {
            this.id = gallery.getId();
            this.couple = gallery.getCouple();
            this.user = gallery.getUser();
            this.imageFilename = gallery.getImageFilename();
            this.imagePath = gallery.getImagePath();
        }

        public static GalleryDto.Response fromEntity(Gallery gallery) {
            return new GalleryDto.Response(gallery);
        }
    }
}
