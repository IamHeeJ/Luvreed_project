package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.CoupleDto;
import com.example.luvreed.application.dto.ScheduleDto;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.service.CoupleService;
import com.example.luvreed.application.service.ScheduleService;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RequiredArgsConstructor
@Slf4j
@RestController
@RequestMapping("/api")
public class ScheduleApiController {
    private final ScheduleService scheduleService;
    private final CoupleService coupleService;
    @GetMapping("/schedule")//ok schedule 불러오기 ex.http://localhost:8080/api/schedule
    public ResponseEntity<List<ScheduleDto.Response>> getSchedule(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                List<ScheduleDto.Response> scheduleList = scheduleService.getAllScheduleByCouple(coupleId);

                return new ResponseEntity<>(scheduleList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/schedule")//ok schedule삽입 http://localhost:8080/api/schedule?memo=중간고사 보기&memo_date=2024-04-25
    public ResponseEntity<ScheduleDto.Response> postSchedule(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                            @RequestParam String memo,
                                                             @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate memo_date) {
        try {
            if (myUserDetails!=null) {
                Long userId = myUserDetails.getUserId();
                Long coupleId = myUserDetails.getCouple().getId();
                Date memoDate = Date.valueOf(memo_date);
                ScheduleDto.Response schedule = scheduleService.postMemo(userId, coupleId, memo, memo_date);

                return new ResponseEntity<>(schedule, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/schedule")//ok schedule 수정 ex.http://localhost:8080/api/schedule?schedule_id=11&memo=학교 데이트
    public ResponseEntity<ScheduleDto.Response> putSchedule(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                  @RequestParam Long schedule_id,
                                                                  @RequestParam String memo) {
        try {
            if (myUserDetails!=null) {
                ScheduleDto.Response schedule = scheduleService.putMemo(schedule_id, memo);

                return new ResponseEntity<>(schedule, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/schedule")//ok schedule 삭제
    public ResponseEntity<List<ScheduleDto.Response>> postSchedule(@AuthenticationPrincipal MyUserDetails myUserDetails,
                                                                   @RequestParam Long schedule_id) {
        try {
            if (myUserDetails!=null) {
                scheduleService.deleteMemo(schedule_id);
                return new ResponseEntity<>(HttpStatus.OK);
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
