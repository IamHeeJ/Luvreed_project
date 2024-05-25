package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Collection;
import lombok.*;

public class CollectionDto {
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
        private Long id;
        private int level;
        private int goalExperience;
        private String explain;
    }

    public Collection toEntity(CollectionDto.Request request) {
        Collection collection = Collection.builder()
                .id(request.getId())
                .level(request.getLevel())
                .goalExperience(request.getGoalExperience())
                .explain(request.getExplain())
                .build();
        return collection;
    }

    @Getter
    public static class Response {
        private final Long id;
        private final int level;
        private final int goalExperience;
        private final String explain;

        public Response(Collection collection) {
            this.id = collection.getId();
            this.level = collection.getLevel();
            this.goalExperience = collection.getGoalExperience();
            this.explain = collection.getExplain();
        }

        public static CollectionDto.Response fromEntity(Collection collection) {
            return new CollectionDto.Response(collection);
        }
    }
}
