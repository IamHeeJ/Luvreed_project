package com.example.luvreed.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class FirstProfileDto {
    @NotBlank(message = "There is no name")
    private String name;

    @NotBlank(message = "There is no dday")
    private String dday;
}
