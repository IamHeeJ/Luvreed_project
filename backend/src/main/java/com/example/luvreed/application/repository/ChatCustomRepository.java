package com.example.luvreed.application.repository;

import com.example.luvreed.application.document.ChatHistory;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface ChatCustomRepository {

    List<ChatHistory> findAllCursorPagingBy(final long chatRoomId, final String chatIdx,
                                            final int size);
}
