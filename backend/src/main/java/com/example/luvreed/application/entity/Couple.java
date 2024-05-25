package com.example.luvreed.application.entity;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Getter
@Setter
@JsonIdentityInfo(generator = ObjectIdGenerators.PropertyGenerator.class, property = "id") //image때문에 추가//직렬화 중복방지
public class Couple {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @JoinColumn(name = "couple_id")
    private Long id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "chatroom_id")
    @JsonIgnore
    private Chatroom chatroom;

    @OneToMany(mappedBy = "couple", fetch = FetchType.EAGER, cascade = CascadeType.REMOVE)
    @JsonIgnore
    @OrderBy("id asc")
    private List<Pet> pet;

    @Column
    private Date dday;
}
