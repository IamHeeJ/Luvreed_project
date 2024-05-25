package com.example.luvreed.application.dto;

import com.example.luvreed.application.entity.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;
import net.sf.jsqlparser.expression.DateTimeLiteralExpression;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

public class ScheduleDto {
    private static final String memoDatePattern = "yyyy-MM-dd";
    private static final String createdAtDatePattern = "yyyy-MM-dd HH:mm:ss";
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @Setter
    @Builder
    public static class Request {
        private Long id;
        private Couple couple;
        private User user;
        private String memo;
        private Date memoDate;
        private Timestamp createdAt;
    }

    public static Schedule toEntity(ScheduleDto.Request request) {
        Schedule schedule = Schedule.builder()
                .id(request.getId())
                .couple(request.getCouple())
                .user(request.getUser())
                .memo(request.getMemo())
                .memoDate((request.getMemoDate()))
                .createdAt(request.getCreatedAt())
                .build();
        return schedule;
    }

    @Getter
    public static class Response {
        private final Long id;

        private final String memo;

        @JsonFormat(pattern = memoDatePattern, timezone = "Asia/Seoul")
        private final Date memoDate;

        @JsonFormat(pattern = createdAtDatePattern, timezone = "Asia/Seoul")
        private final Timestamp createdAt;

        public Response(Schedule schedule) {
            this.id = schedule.getId();
            this.memo = schedule.getMemo();
            this.memoDate = schedule.getMemoDate();
            this.createdAt = schedule.getCreatedAt();
        }

        public static ScheduleDto.Response fromEntity(Schedule schedule) {
            return new ScheduleDto.Response(schedule);
        }

        public static List<Response> fromEntityList(List<Schedule> scheduleList) {
            return scheduleList.stream()
                    .map(Response::fromEntity)
                    .collect(Collectors.toList());
        }
    }
}
