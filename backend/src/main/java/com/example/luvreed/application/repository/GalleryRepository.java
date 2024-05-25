package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Gallery;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GalleryRepository extends JpaRepository<Gallery, Long> {
    void deleteByUserId(Long userId);
}
