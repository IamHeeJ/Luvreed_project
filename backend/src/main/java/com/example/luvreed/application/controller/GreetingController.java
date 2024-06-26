package com.example.luvreed.application.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.util.HtmlUtils;

@Controller
public class GreetingController {

    @MessageMapping("/hello")
    @SendTo("/topic/greetings")
    public GreetingResponse greeting(final HelloMessageRequest message) throws InterruptedException {
        // simulated delay
        // 클라이언트가 메시지를 보낸 후 서버가 메시지를 비동기식으로 처리하는 데 필요한 시간만큼 오래 걸릴 수 있음을 보여주기 위한 것
        Thread.sleep(1000);

        return new GreetingResponse("Hello, " + HtmlUtils.htmlEscape(message.name()) + " !!");
    }

    public record GreetingResponse(String content){

    }

    public record HelloMessageRequest(String name) {

    }
}
