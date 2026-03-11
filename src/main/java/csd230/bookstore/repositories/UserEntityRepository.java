package csd230.bookstore.repositories;
import csd230.bookstore.entities.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
public interface UserEntityRepository extends JpaRepository<UserEntity, Long> {
    UserEntity findByUsername(String username);
}


