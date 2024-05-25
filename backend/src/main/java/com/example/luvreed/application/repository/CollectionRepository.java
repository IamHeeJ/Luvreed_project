package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Collection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CollectionRepository extends JpaRepository<Collection, Long> {

//    @Query(value = "SELECT c FROM Collection c WHERE c.id = :originCollection.id + 1", nativeQuery = true)
//    Optional<Collection> findByCollection(@Param("originCollection") Collection originCollection);

    @Query("SELECT c FROM Collection c WHERE c.id = :id + 1")
    Optional<Collection> findByCollection(@Param("id") Long id);

}
