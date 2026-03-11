package csd230.bookstore.controllers;

import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.entities.ProductEntity;
import csd230.bookstore.repositories.CartEntityRepository;
import csd230.bookstore.repositories.ProductEntityRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rest/cart")
@CrossOrigin(origins = "*")
public class CartRestController {
    private final CartEntityRepository cartRepository;
    private final ProductEntityRepository productRepository;

    public CartRestController(CartEntityRepository cartRepository, ProductEntityRepository productRepository) {
        this.cartRepository = cartRepository;
        this.productRepository = productRepository;
    }

    @GetMapping
    public CartEntity getCart() {
        // Targets the default cart created in Application.java
        return cartRepository.findById(1L).orElseThrow();
    }

    @PostMapping("/add/{productId}")
    public CartEntity addToCart(@PathVariable Long productId) {
        CartEntity cart = cartRepository.findById(1L).orElseThrow();
        ProductEntity product = productRepository.findById(productId).orElseThrow();
        cart.addProduct(product);
        return cartRepository.save(cart);
    }

    @DeleteMapping("/remove/{productId}")
    public CartEntity removeFromCart(@PathVariable Long productId) {
        CartEntity cart = cartRepository.findById(1L).orElseThrow();
        ProductEntity product = productRepository.findById(productId).orElseThrow();
        cart.getProducts().remove(product);
        return cartRepository.save(cart);
    }
}

