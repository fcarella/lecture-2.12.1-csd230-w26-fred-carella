package csd230.bookstore.controllers;
import csd230.bookstore.entities.BookEntity;
import csd230.bookstore.entities.CartEntity;
import csd230.bookstore.repositories.BookEntityRepository;
import csd230.bookstore.repositories.CartEntityRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
@Controller
@RequestMapping("/cart")
public class CartController {
    @Autowired
    private CartEntityRepository cartRepository;
    @Autowired
    private BookEntityRepository bookRepository;
    // 1. View the contents of the cart
    @GetMapping
    public String viewCart(Model model) {
        // HARDCODED ID: In a real app, this comes from the Session or SecurityContext
        Long defaultCartId = 1L;

        // Find cart with ID 1, or create a temporary empty one if not found
        CartEntity cart = cartRepository.findById(defaultCartId)
                .orElseGet(() -> {
                    CartEntity newCart = new CartEntity();
                    newCart.setId(defaultCartId);
                    return cartRepository.save(newCart); // Save it so it exists
                });
        model.addAttribute("cart", cart);
        return "cartDetails";
    }
    // 2. Add a specific book to the cart
//    @GetMapping("/add/{bookId}")
//    public String addToCart(@PathVariable Long bookId) {
//        Long defaultCartId = 1L;
//        CartEntity cart = cartRepository.findById(defaultCartId).orElse(null);
//        BookEntity book = bookRepository.findById(bookId).orElse(null);
//        if (cart != null && book != null) {
//            cart.addProduct(book); // Uses the helper method in CartEntity
//            cartRepository.save(cart); // Updates the Join Table
//        }
//        return "redirect:/books"; // Send them back to the shopping list
//    }
    @GetMapping("/add/{bookId}")
    public String addToCart(@PathVariable Long bookId) {
        // Find the first available cart
        CartEntity cart = cartRepository.findAll().stream().findFirst().orElse(null);
        BookEntity book = bookRepository.findById(bookId).orElse(null);

        if (cart != null && book != null) {
            cart.addProduct(book);
            cartRepository.save(cart);
        }
        return "redirect:/books";
    }
    // 3. Remove item from cart
    @GetMapping("/remove/{bookId}")
    public String removeFromCart(@PathVariable Long bookId) {
        Long defaultCartId = 1L;
        CartEntity cart = cartRepository.findById(defaultCartId).orElse(null);
        BookEntity book = bookRepository.findById(bookId).orElse(null);
        if(cart != null && book != null) {
            cart.getProducts().remove(book);
            cartRepository.save(cart);
        }
        return "redirect:/cart";
    }
}

