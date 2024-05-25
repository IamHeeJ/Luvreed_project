package com.example.luvreed.application.repository;

import com.example.luvreed.application.document.ChatHistory;
import lombok.RequiredArgsConstructor;
import org.bson.types.ObjectId;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Objects;

@Repository
public interface ChatRepository extends MongoRepository<ChatHistory, String>, ChatCustomRepository {
    List<ChatHistory> findByChatroomIdOrderByCreatedAtDesc(Long chatroomId, Pageable pageable);

    List<ChatHistory> findAllByChatroomId(Long chatroomId);

    void deleteByCoupleId(Long coupleId);
}

