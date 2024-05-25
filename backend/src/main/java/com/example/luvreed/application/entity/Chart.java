package com.example.luvreed.application.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.util.Date;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Getter
public class Chart {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "couple_id")
    @OnDelete(action = OnDeleteAction.CASCADE)
    private Couple couple;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column
    private int happy;

    @Column
    private int surprised;

    @Column
    private int anxious;

    @Column
    private int angry;

    @Column
    private int sad;

    @Column
    private int annoyed;

    @Column
    private int neutral;

    @Column
    @JoinColumn(name = "date")
    private Date date;
}
