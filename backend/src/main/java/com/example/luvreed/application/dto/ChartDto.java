package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public class ChartDto {
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
    public static class Response {
        private final Long id;
        private final Long userId;
        private final int happy;
        private final int surprised;
        private final int anxious;
        private final int sad;
        private final int angry;
        private final int annoyed;
        private final int neutral;
        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private final Date date;

        public Response(Chart chart) {
            this.id = chart.getId();
            this.userId = chart.getUser().getId();
            this.happy = chart.getHappy();
            this.surprised = chart.getSurprised();
            this.anxious = chart.getAnxious();
            this.sad = chart.getSad();
            this.angry = chart.getAngry();
            this.annoyed = chart.getAnnoyed();
            this.neutral = chart.getNeutral();
            this.date = chart.getDate();
        }

        public static ChartDto.Response fromEntity(Chart chart) {
            return new ChartDto.Response(chart);
        }

        public static List<ChartDto.Response> fromEntityList(List<Chart> chartList) {
            return chartList.stream()
                    .map(ChartDto.Response::fromEntity)
                    .collect(Collectors.toList());
        }
    }
}
