package com.example.luvreed.application.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.Random;

@Slf4j
@RequiredArgsConstructor
@Service
public class AiService {
    private static final String PYTHON_SCRIPT_PATH = "C:\\Luvreed\\luvreed_0525\\src\\main\\java\\com\\example\\luvreed\\application\\service\\predict.py";
    private static final String DEFAULT_EMOTION = "감정 없음";

    public String getEmotion(String message) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder("python", PYTHON_SCRIPT_PATH);
            Process process = processBuilder.start();

            // Write the message to the process's input stream
            process.getOutputStream().write(message.getBytes());
            process.getOutputStream().flush();
            process.getOutputStream().close();

            // Read the output from the process
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String output = reader.readLine();
            reader.close();

            // Return the random emotion
            // Return the predicted emotion
            if (output != null ) {
                return output;
            }else if(output.isEmpty()) {
                log.warn("Empty output from Python script");
            }else if(output == null) {
                log.warn("null from Python script");
            }else {
                log.warn("Empty or invalid output from Python script");
                return DEFAULT_EMOTION;
            }
        } catch (IOException e) {
            log.error("Error executing Python script", e);
        }
        return null;
    }
}
