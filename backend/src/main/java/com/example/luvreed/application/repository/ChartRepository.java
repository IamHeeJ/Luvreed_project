package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Chart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ChartRepository extends JpaRepository<Chart, Long> {
    @Query(value = "SELECT * FROM Chart WHERE couple_id = :coupleId AND DATE(Date) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)", nativeQuery = true)
    List<Chart> findAllByCoupleIdAndYesterday(@Param("coupleId") Long coupleId);
    @Query(value = "SELECT * FROM Chart WHERE couple_id = :coupleId AND DATE(Date) BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()", nativeQuery = true)
    List<Chart> findAllByCoupleIdAndLastWeek(@Param("coupleId") Long coupleId);
    @Query(value = "SELECT * FROM Chart WHERE couple_id = :coupleId AND DATE(Date) BETWEEN DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND CURDATE()", nativeQuery = true)
    List<Chart> findAllByCoupleIdAndLastMonth(@Param("coupleId") Long coupleId);
    List<Chart> findAllByCoupleId(Long coupleId);

    @Modifying
    @Query(value = "INSERT INTO Chart (user_id, couple_id, happy, surprised, anxious, angry, sad, annoyed, neutral, date) " +
            "SELECT :userId, :coupleId, 0, 0, 0, 0, 0, 0, 0, DATE_FORMAT(NOW(), '%Y-%m-%d 00:00:00.000000') " +
            "FROM dual " +
            "WHERE NOT EXISTS (" +
            "    SELECT 1 FROM Chart " +
            "    WHERE user_id = :userId AND couple_id = :coupleId AND DATE(date) = CURDATE()" +
            ")", nativeQuery = true)
    void insertEmotionByUserIdAndDate(@Param("userId") Long userId, @Param("coupleId") Long coupleId);

    @Modifying
    @Query(value = "UPDATE Chart " +
            "SET happy = happy + CASE WHEN :emotion = 'happy' THEN 1 ELSE 0 END, " +
            "surprised = surprised + CASE WHEN :emotion = 'surprised' THEN 1 ELSE 0 END, " +
            "anxious = anxious + CASE WHEN :emotion = 'anxious' THEN 1 ELSE 0 END, " +
            "angry = angry + CASE WHEN :emotion = 'angry' THEN 1 ELSE 0 END, " +
            "sad = sad + CASE WHEN :emotion = 'sad' THEN 1 ELSE 0 END, " +
            "annoyed = annoyed + CASE WHEN :emotion = 'annoyed' THEN 1 ELSE 0 END, " +
            "neutral = neutral + CASE WHEN :emotion = 'neutral' THEN 1 ELSE 0 END " +
            "WHERE user_id = :userId AND couple_id = :coupleId AND DATE(date) = CURDATE()", nativeQuery = true)
    void updateEmotionByUserIdAndDate(@Param("emotion") String emotion, @Param("userId") Long userId, @Param("coupleId") Long coupleId);

    boolean existsByUserIdAndCoupleIdAndDateBetween(Long userId, Long coupleId, LocalDateTime startDate, LocalDateTime endDate);

    void deleteByCoupleId(Long coupleId);
}
