package csd230.bookstore.pojos;

import csd230.bookstore.entities.CartEntity;

import java.util.List;
import java.util.Objects;
/**
 * DTO for {@link csd230.bookstore.entities.CartEntity}
 */
/**
 * DTO for {@link CartEntity}
 */
public class Cart {
    private List<Product> items;

    public Cart() {
    }

    public Cart(List<Product> items) {
        this.items = items;
    }

    public void addItem(Product item) {
        items.add(item);
    }

    public List<Product> getItems() {
        return items;
    }

    public void setItems(List<Product> items) {
        this.items = items;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Cart cart)) return false;
        return Objects.equals(getItems(), cart.getItems());
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(getItems());
    }

    @Override
    public String toString() {
        return "Cart{" +
                "items=" + items +
                '}';
    }
}
