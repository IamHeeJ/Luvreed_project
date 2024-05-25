package com.example.luvreed.application.entity;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum Role {
    COUPLE("ROLE_COUPLE", "커플"),
    SOLO("ROLE_SOLO", "솔로"),
    ADMIN("ROLE_ADMIN", "관리자");

    private final String key;
    private final String title;
}
