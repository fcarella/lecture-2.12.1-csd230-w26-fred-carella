package csd230.bookstore.pojos;

import java.io.Serializable;

// Marked abstract because it implements SaleableItem but doesn't implement getPrice()
// (Price is defined in children: Ticket and Publication)
public abstract class Product extends Editable implements SaleableItem, Serializable {
    private String productId;

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    private Cart cart;

}
