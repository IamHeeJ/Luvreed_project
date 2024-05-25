package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.PetDto;
import com.example.luvreed.application.entity.Pet;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.service.PetService;
import com.example.luvreed.application.service.CoupleService;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api")
@RestController
public class PetApiController {
    private final PetService petService;
    private final CoupleService coupleService;

    @GetMapping("/pet")//selection 이 true인 pet을 get.
    public ResponseEntity<PetDto.Response> getPetBycoupleId(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Couple couple = myUserDetails.getCouple();
                Optional<Pet> petOptional = petService.findPetByCouple(couple);
                Pet pet = petOptional.orElseThrow(() ->
                        new IllegalArgumentException("해당 캐릭터가 존재하지 않습니다. username: " + petOptional));
                //CharactarDto charactarDto = new CharactarDto.Response(charactar);
                return ResponseEntity.ok(new PetDto.Response(pet));

            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/petlist")//selection 이 true인 pet을 get.
    public ResponseEntity<List<PetDto.Response>> getPetListBycoupleId(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Couple couple = myUserDetails.getCouple();
                List<Pet> petList = petService.findPetListByCouple(couple);
//                List<Pet> pet = petList.orElseThrow(() ->
//                        new IllegalArgumentException("해당 캐릭터가 존재하지 않습니다. username: " + petOptional));
                //CharactarDto charactarDto = new CharactarDto.Response(charactar);
                return ResponseEntity.ok(PetDto.Response.fromEntityList(petList));

            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/petchange")//도감에서 4개의 펫 중 하나를 고름. 고르는 펫은 selection -> true, 나머지 펫은 selection -> false
    public ResponseEntity<PetDto.Response> updatePetListBycoupleId(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                         @RequestParam Long id) {
        try {
            if (myUserDetails != null) {
                Couple couple = myUserDetails.getCouple();
                petService.updatePetByCouple(couple, id);
                Optional<Pet> petOptional = petService.findPetByCouple(couple);
                Pet pet = petOptional.orElseThrow(() ->
                        new IllegalArgumentException("해당 캐릭터가 존재하지 않습니다. username: " + petOptional));
                //CharactarDto charactarDto = new CharactarDto.Response(charactar);
                return ResponseEntity.ok(new PetDto.Response(pet));

            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
