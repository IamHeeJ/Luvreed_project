package com.example.luvreed.application.entity;

import jakarta.persistence.*;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Getter
@Setter
public class Pet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "couple_id")
    private Couple couple;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "collection_id")
    private Collection collection;

    @Column(nullable = false)
    private int experience;

    @Column
    private Boolean selection;
}
