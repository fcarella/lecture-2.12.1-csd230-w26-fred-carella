package csd230.bookstore.repositories;

import csd230.bookstore.entities.BookEntity;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BookEntityRepository extends JpaRepository<BookEntity, Long> {

    // We can now add book-specific queries here if needed, e.g.:

    // List<BookEntity> findByAuthor(String author);

}
