package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Profile;
import com.example.luvreed.application.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.beans.JavaBean;
import java.util.Optional;

@Repository
public interface ProfileRepository extends JpaRepository<Profile, Long> {
    Optional<Profile> getProfileByUserId(Long userId);

    @Modifying
    @Transactional
    @Query("UPDATE Profile p SET p.imagePath = :imagePath WHERE p.user.id = :loverId")
    void updateImagePathByUser(@Param("loverId") Long loverId, @Param("imagePath") String imagePath);

    void deleteByUserId(Long userId);
}
