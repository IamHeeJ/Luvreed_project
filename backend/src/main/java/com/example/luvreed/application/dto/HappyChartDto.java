package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.Chart;
import com.example.luvreed.application.entity.Couple;
import com.example.luvreed.application.entity.User;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public class HappyChartDto {
    private static final String memoDatePattern = "yyyy-MM-dd";
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
        private Long id;
        private Couple couple;
        private User user;
        private int happy;
        private int surprised;
        private int anxious;
        private int angry;
        private int sad;
        private int annoyed;
        private int neutral;
        private Date date;
    }

    public Chart toEntity(ChartDto.Request request) {
        Chart chart = Chart.builder()
                .id(request.getId())
                .couple(request.getCouple())
                .user(request.getUser())
                .happy(request.getHappy())
                .surprised(request.getSurprised())
                .anxious(request.getAnxious())
                .angry(request.getAngry())
                .sad(request.getSad())
                .annoyed(request.getAnnoyed())
                .neutral(request.getNeutral())
                .date(request.getDate())
                .build();
        return chart;
    }

    @Getter
    @AllArgsConstructor
    public static class Response {
        private final Long id;
        private final Long userId;
        private final int happy;
        private final int daysAgo;
        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private final Date date;

        public static HappyChartDto.Response fromEntity(Chart chart) {
            return new HappyChartDto.Response(
                    chart.getId(),
                    chart.getUser().getId(),
                    chart.getHappy(),
                    (int) ChronoUnit.DAYS.between(chart.getDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate(), LocalDate.now()),
                    chart.getDate()
            );
        }

        public static List<HappyChartDto.Response> fromEntityList(List<Chart> chartList) {
            return chartList.stream()
                    .map(HappyChartDto.Response::fromEntity)
                    .collect(Collectors.toList());
        }
    }
}
