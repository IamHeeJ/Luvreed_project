package com.example.luvreed.application.document;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;
import org.springframework.data.mongodb.core.mapping.FieldType;

import java.util.Date;

@Getter
@Document(collection = "chatHistory")
@NoArgsConstructor
//@EntityListeners(AuditingEntityListener.class)
@Setter
public class ChatHistory {

    @Id
    private String id;

    @Field("userId")
    private Long userId;

    @Field("coupleId")
    private Long coupleId;

    @Field("chatroomId")
    private Long chatroomId;

    @Field("text")
    private String text;

    @Field("emotion")
    private String emotion;

    @Field("checked")
    private String checked;

    @Field("imgUrl")
    private String imagePath;

    @Field("createdAt")
    @CreatedDate
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
    private Date createdAt;
}
//    private String userId;
//    private String coupleId;
//    private String chatroomId;
//    private String text;
//    private String emotion;
//    private String checked;
//    private String imgUrl;
//    private String createdAt;