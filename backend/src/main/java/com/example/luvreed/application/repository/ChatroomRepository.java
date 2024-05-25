package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Chatroom;
import com.example.luvreed.application.entity.Couple;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import javax.swing.text.html.Option;
import java.util.Optional;

@Repository
public interface ChatroomRepository extends JpaRepository<Chatroom, Long> {

    Optional<Chatroom> findAllByCouple(Couple couple);
}
