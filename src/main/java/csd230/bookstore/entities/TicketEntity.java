package csd230.bookstore.entities;

import jakarta.persistence.Column;
import jakarta.persistence.DiscriminatorValue;
import jakarta.persistence.Entity;

@Entity @DiscriminatorValue("TICKET")
public class TicketEntity extends ProductEntity {
    private String description;
    @Column(name = "ticket_price")
    private Double price; // Capital 'D' Double
    public TicketEntity() {}
    public TicketEntity(String d, Double p) { this.description = d; this.price = p; }

    @Override public void sellItem() { System.out.println("Selling Ticket: " + description + " for $" + price); }
    @Override public Double getPrice() { return price; }
    public void setPrice(Double price) {
        this.price = price;
    }

    public String getDescription() { return description; }
    public void setDescription(String d) { this.description = d; }
    @Override public String toString() { return "Ticket{desc='" + description + "', price=" + price + "}"; }
}
