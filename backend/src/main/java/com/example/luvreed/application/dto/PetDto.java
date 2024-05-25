package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Chart;
import com.example.luvreed.application.entity.Pet;
import com.example.luvreed.application.entity.Collection;
import com.example.luvreed.application.entity.Couple;
import lombok.*;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class PetDto {

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
        private Long id;
        private Couple couple;
        private Collection collection;
        private int experience;
        private boolean selection;
    }

    public Pet toEntity(Request request) {
        Pet pet = Pet.builder()
                .id(request.getId())
                .couple(request.getCouple())
                .collection(request.getCollection())
                .experience(request.getExperience())
                .selection(request.isSelection())
                .build();
        return pet;
    }

    @Getter
    public static class Response {
        private final Long id;
        //private final Couple couple;
        private final Collection collection;
        private final int experience;
        private final boolean selection;

        public Response(Pet pet) {
            this.id = pet.getId();
            //this.couple = pet.getCouple();
            this.collection = pet.getCollection();
            this.experience = pet.getExperience();
            this.selection = pet.getSelection();
        }

        public static Response fromEntity(Pet pet) {
            return new Response(pet);
        }

        public static List<PetDto.Response> fromEntityList(List<Pet> petList) {
            return petList.stream()
                    .map(PetDto.Response::fromEntity)
                    .collect(Collectors.toList());
        }
    }


}
