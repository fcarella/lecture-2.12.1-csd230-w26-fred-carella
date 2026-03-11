package csd230.bookstore.repositories;

import csd230.bookstore.entities.MagazineEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MagazineEntityRepository extends JpaRepository<MagazineEntity, Long> {
}