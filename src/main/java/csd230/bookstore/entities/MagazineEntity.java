package csd230.bookstore.entities;

import com.fasterxml.jackson.annotation.JsonFormat; // NEW
import com.fasterxml.jackson.annotation.JsonIgnore; // NEW
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

import java.time.LocalDateTime;
import java.util.Objects;

@Entity @DiscriminatorValue("MAGAZINE")
public class MagazineEntity extends PublicationEntity {
    private int orderQty;

    // NEW: Tells Spring exactly how to parse the React date string
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime currentIssue;

    public MagazineEntity() {}

    // NEW: Forces Spring to ignore this and use the empty constructor + setters
    @JsonIgnore
    public MagazineEntity(String t, double p, int c, int o, LocalDateTime d) {
        super(t, p, c);
        this.orderQty = o;
        this.currentIssue = d;
    }

    public int getOrderQty() { return orderQty; }
    public void setOrderQty(int o) { this.orderQty = o; }
    public void setCurrentIssue(LocalDateTime d) { this.currentIssue = d; }
    public LocalDateTime getCurrentIssue() { return currentIssue; }

    @Override
    public String toString() { return "Mag{issue=" + currentIssue + ", " + super.toString() + "}"; }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        MagazineEntity that = (MagazineEntity) o;
        return orderQty == that.orderQty && Objects.equals(currentIssue, that.currentIssue);
    }

    @Override
    public int hashCode() {
        return Objects.hash(orderQty, currentIssue);
    }
}
