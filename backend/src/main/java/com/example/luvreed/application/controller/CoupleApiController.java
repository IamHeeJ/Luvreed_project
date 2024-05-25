package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.CoupleDto;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.service.CoupleService;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Optional;

@RequiredArgsConstructor
@Slf4j
@RestController
@RequestMapping("/api")
public class CoupleApiController {
    private final CoupleService coupleService;
    //private final UserService userService;

    @GetMapping("/dday")//ok
    public ResponseEntity<CoupleDto.Response> getDdayByCouple(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                Optional<Couple> coupleOptional = coupleService.findCoupleById(coupleId);
                Couple couple = coupleOptional.orElseThrow(() ->
                        new IllegalArgumentException("해당 커플이 존재하지 않습니다. username: " + coupleOptional));
                return ResponseEntity.ok(new CoupleDto.Response(couple));
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/dday")
    public ResponseEntity<CoupleDto.Response> putDdayByCouple(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                @RequestParam String dday) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                Date parsedDday = new SimpleDateFormat("yyyy-MM-dd").parse(dday);
                coupleService.putDdayById(coupleId, parsedDday);
                Optional<Couple> optionalCouple = coupleService.findCoupleById(coupleId);
                if (optionalCouple.isPresent()) {
                    Couple couple = optionalCouple.get();
                    return ResponseEntity.ok(new CoupleDto.Response(couple));
                } else {
                    return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                }
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
