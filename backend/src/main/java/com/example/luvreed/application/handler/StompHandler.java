package com.example.luvreed.application.handler;

import com.example.luvreed.jwt.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Order(Ordered.HIGHEST_PRECEDENCE + 99)
public class StompHandler implements ChannelInterceptor {

    private final JwtProvider jwtUtils;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {

        final StompHeaderAccessor accessor = StompHeaderAccessor.wrap((org.springframework.messaging.Message<?>) message);

        if (StompCommand.CONNECT == accessor.getCommand() || StompCommand.SEND == accessor.getCommand()) {
            final String authorization = jwtUtils.extractJwt(accessor);

            try {
                jwtUtils.validateAccessToken(authorization);
            } catch (Exception e) {
                throw new BadCredentialsException("Invalid JWT token", e);
            }
        }

        return message;
    }
}
