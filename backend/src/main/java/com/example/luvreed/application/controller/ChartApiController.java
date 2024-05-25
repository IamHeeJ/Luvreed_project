package com.example.luvreed.application.controller;

import com.example.luvreed.application.dto.ChartDto;
import com.example.luvreed.application.dto.HappyChartDto;
import com.example.luvreed.application.entity.Chart;
import com.example.luvreed.application.repository.ChartRepository;
import com.example.luvreed.application.service.ChartService;
import com.example.luvreed.application.service.UserService;
import com.example.luvreed.security.MyUserDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Slf4j
@RequiredArgsConstructor
@RequestMapping("/api")
@RestController
public class ChartApiController {
    private final ChartService chartService;
    private final ChartRepository chartRepository;
    private final UserService userService;
    @GetMapping("/emotionofyesterday")
    public ResponseEntity<List<ChartDto.Response>> getEmotionofYesterday(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                List<ChartDto.Response> chartList = chartService.getYesterdayemotionByCoupleId(coupleId);
                return new ResponseEntity<>(chartList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/happyoflastweek")
    public ResponseEntity<List<HappyChartDto.Response>> getHappyofLastWeek(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Long coupleId = myUserDetails.getCouple().getId();
                Long userId = myUserDetails.getUserId();
                Long loverId = userService.getLover(userId, coupleId);
                List<Chart> chartList = chartRepository.findAllByCoupleIdAndLastWeek(coupleId);
                List<HappyChartDto.Response> responseList = new ArrayList<>();

                // 6일 전부터 1일 전까지의 날짜 리스트 생성
                List<LocalDate> dateList = new ArrayList<>();
                for (int i = 7; i >= 1; i--) {
                    dateList.add(LocalDate.now().minusDays(i));
                }

                // 12개의 리스트 생성
                for (LocalDate date : dateList) {
                    for (Long id : Arrays.asList(userId, loverId)) {
                        boolean dataExists = false;
                        for (Chart chart : chartList) {
                            if (chart.getDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate().equals(date) &&
                                    chart.getUser().getId().equals(id)) {
                                responseList.add(HappyChartDto.Response.fromEntity(chart));
                                dataExists = true;
                                break;
                            }
                        }
                        if (!dataExists) {
                            HappyChartDto.Response defaultResponse = new HappyChartDto.Response(
                                    null,
                                    id,
                                    0,
                                    (int) ChronoUnit.DAYS.between(date, LocalDate.now()),
                                    Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant())
                            );
                            responseList.add(defaultResponse);
                        }
                    }
                }

                return new ResponseEntity<>(responseList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching happy data", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/happyoflastmonth")
    public ResponseEntity<List<HappyChartDto.Response>> getHappyofLastMonth(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails != null) {
                Long coupleId = myUserDetails.getCouple().getId();
                Long userId = myUserDetails.getUserId();
                Long loverId = userService.getLover(userId, coupleId);
                List<Chart> chartList = chartRepository.findAllByCoupleIdAndLastMonth(coupleId);
                List<HappyChartDto.Response> responseList = new ArrayList<>();

                // 29일 전부터 1일 전까지의 날짜 리스트 생성
                List<LocalDate> dateList = new ArrayList<>();
                for (int i = 30; i >= 1; i--) {
                    dateList.add(LocalDate.now().minusDays(i));
                }

                // 58개의 리스트 생성
                for (LocalDate date : dateList) {
                    for (Long id : Arrays.asList(userId, loverId)) {
                        boolean dataExists = false;
                        for (Chart chart : chartList) {
                            if (chart.getDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate().equals(date) &&
                                    chart.getUser().getId().equals(id)) {
                                responseList.add(HappyChartDto.Response.fromEntity(chart));
                                dataExists = true;
                                break;
                            }
                        }
                        if (!dataExists) {
                            HappyChartDto.Response defaultResponse = new HappyChartDto.Response(
                                    null,
                                    id,
                                    0,
                                    (int) ChronoUnit.DAYS.between(date, LocalDate.now()),
                                    Date.from(date.atStartOfDay(ZoneId.systemDefault()).toInstant())
                            );
                            responseList.add(defaultResponse);
                        }
                    }
                }

                return new ResponseEntity<>(responseList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching happy data", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/emotionoflastweek")//모든 감정을 get
    public ResponseEntity<List<ChartDto.Response>> getEmotionofLastWeek(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                List<ChartDto.Response> chartList = chartService.getLastWeekemotionByCoupleId(coupleId);
                return new ResponseEntity<>(chartList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/emotionoflastmonth")
    public ResponseEntity<List<ChartDto.Response>> getEmotionofLastMonth(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                List<ChartDto.Response> chartList = chartService.getLastMonthemotionByCoupleId(coupleId);
                return new ResponseEntity<>(chartList, HttpStatus.OK);
            } else {
                log.info("User not authenticated.");
                return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
            }
        } catch (Exception e) {
            log.error("Error while fetching username", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/emotionofschedule")
    public ResponseEntity<List<ChartDto.Response>> getEmotionofSchedule(@AuthenticationPrincipal MyUserDetails myUserDetails) {
        try {
            if (myUserDetails!=null) {
                Long coupleId = myUserDetails.getCouple().getId();
                List<ChartDto.Response> chartList = chartService.getAllemotionByCoupleId(coupleId);
                return new ResponseEntity<>(chartList, HttpStatus.OK);
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
