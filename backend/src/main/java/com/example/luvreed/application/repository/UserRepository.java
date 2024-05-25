package com.example.luvreed.application.repository;

import com.example.luvreed.application.dto.UserDto;
import com.example.luvreed.application.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    @Query(value = "SELECT u.id FROM User u WHERE u.couple_id = :coupleId AND u.id <> :excludedUserId", nativeQuery = true)
    Long findUsersByCoupleIdExcludingUser(@Param("coupleId") Long coupleId, @Param("excludedUserId") Long excludedUserId);

    User findByCode(String code);

    @Transactional
    @Modifying
    @Query("UPDATE User u SET u.code = :inviteCode WHERE u = :user")
    void updateCodeByUser(@Param("user") User user, @Param("inviteCode") String inviteCode);

    List<User> findUsersByCoupleId(Long coupleId); //추가

    @Modifying
    @Transactional
    @Query("UPDATE User u SET u.password = :password WHERE u.id = :userId")
    void updatePasswordByUser(@Param("userId") Long userId, @Param("password") String newpassword);
}
