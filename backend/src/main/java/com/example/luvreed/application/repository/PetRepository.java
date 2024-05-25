package com.example.luvreed.application.repository;

import com.example.luvreed.application.entity.Collection;
import com.example.luvreed.application.entity.Pet;
import com.example.luvreed.application.entity.Couple;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
@Repository
public interface PetRepository extends JpaRepository<Pet, Long> {

//    @Query("SELECT c FROM Charactar c WHERE c.coupleId = :coupleId AND c.selection = true")
//    Optional<Charactar> findCharactarByCoupleId(Long id);
    //@Query("SELECT c FROM Pet c WHERE c.couple.id = :coupleId AND c.selection = true")
    Optional<Pet> findPetByCoupleAndSelectionIsTrue(@Param("coupleId") Couple couple);

    List<Pet> findAllByCouple(Couple couple);

    @Transactional
    @Modifying
    @Query("UPDATE Pet p SET p.selection = CASE WHEN p.id = :pickedPetid THEN TRUE ELSE FALSE END WHERE p.couple = :couple")
    void updatePetsByCoupleAndSelectionIsTrueAndOtherIsFalse(@Param("couple") Couple couple, @Param("pickedPetid") Long pickedPetid);

    @Modifying
    @Query("UPDATE Pet p SET p.experience = p.experience + 2 WHERE p.couple.id = :coupleId AND p.selection = true")
    void updatePetExperienceByCoupleAndSelectionIsTrue(@Param("coupleId") Long coupleId);

    @Modifying
    @Query("UPDATE Pet p SET p.collection = :newCollection WHERE p.couple = :couple AND p.selection = true AND p.collection = :originCollection")
    void updatePetsCollectionByCouple(@Param("couple") Couple couple,
                                      @Param("originCollection") Collection originCollection, @Param("newCollection") Collection newCollection);

    void deleteByCoupleId(Long coupleId);
}
