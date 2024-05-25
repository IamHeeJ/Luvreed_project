//package com.example.luvreed.application.repository;
//
//import com.example.luvreed.application.document.ChatHistory;
//import lombok.RequiredArgsConstructor;
//import org.bson.types.ObjectId;
//import org.springframework.data.domain.Sort;
//import org.springframework.data.mongodb.core.MongoTemplate;
//import org.springframework.data.mongodb.core.query.Criteria;
//import org.springframework.data.mongodb.core.query.Query;
//import org.springframework.stereotype.Repository;
//
//import java.util.List;
//import java.util.Objects;
//
//@RequiredArgsConstructor
//public class ChatCustomRepositoryImpl implements ChatCustomRepository {
//    private final MongoTemplate mongoTemplate;
//
//    @Override
//    public List<ChatHistory> findAllCursorPagingBy(long chatRoomId, String chatIdx, int size) {
//        Query query = new Query();
//        query.addCriteria(Criteria.where("chatroomId").is(chatRoomId));
//        if (chatIdx != null) {
//            query.addCriteria(Criteria.where("id").lt(chatIdx));
//        }
//        query.with(Sort.by(Sort.Direction.DESC, "createdAt"));
//        query.limit(size);
//        return mongoTemplate.find(query, ChatHistory.class);
//    }
//}
//
