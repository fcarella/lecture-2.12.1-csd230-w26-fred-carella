package csd230.bookstore.pojos;

import java.util.Objects;

public class Book extends Publication {
    private String author = "";

    public Book() {
        super();
    }

    public Book(String author) {
        this.author = author;
    }

    public Book(String author, String title, double price, int copies) {
        super(title, price, copies);
        this.author = author;
    }

    @Override
    public void initialize() {
        // 1. Initialize Parent (Title)
        super.initialize();

        // 2. Initialize Self (Author)
        System.out.println("Enter Author:");
        this.author = getInput("Unknown Author");

        // 3. Initialize Parent (Copies/Price)
        super.initPriceCopies();
    }

    @Override
    public void edit() {
        // 1. Edit Parent fields (Title, Price, Copies)
        super.edit();

        // 2. Edit Self fields
        System.out.println("Edit Author [" + this.author + "]:");
        this.author = getInput(this.author);
    }

    @Override
    public void sellItem() {
        System.out.println("Selling Book: " + getTitle() + " by " + author);
        setCopies(getCopies() - 1);
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    @Override
    public String toString() {
        return "Book{author='" + author + "', " + super.toString() + "}";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Book)) return false;
        if (!super.equals(o)) return false;
        Book book = (Book) o;
        return Objects.equals(author, book.author);
    }

    @Override
    public int hashCode() {
        return Objects.hash(super.hashCode(), author);
    }
}
