package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Couple;
import org.springframework.data.jdbc.repository.query.Modifying;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.Optional;

@Repository
public interface CoupleRepository extends JpaRepository<Couple, Long> {
    Optional<Couple> findCoupleById(Long id);

    @Query(value = "UPDATE Couple c SET c.dday = :dday WHERE c.id = :coupleid", nativeQuery = true)
    void updateDdayByCoupleId(@Param("coupleid") Long coupleid, @Param("dday") Date dday);
    //JPQL 쿼리를 사용하면 엔티티 객체를 반환할 수 있습니다.
    // 반면에 네이티브 SQL 쿼리를 사용하면 데이터베이스 레코드를 반환하게 되어 Couple 엔티티 객체를 반환할 수 없습니다.
}
