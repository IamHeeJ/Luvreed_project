package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ScheduleRepository extends JpaRepository<Schedule, Long> {

    List<Schedule> findAllByCoupleId(Long coupleId);

    void deleteByUserId(Long userId);

    void deleteBycoupleId(Long coupleId);

    @Modifying
    @Query("DELETE FROM Schedule s WHERE s.id = :scheduleId")
    void deleteByScheduleId(@Param("scheduleId") Long scheduleId);
}
