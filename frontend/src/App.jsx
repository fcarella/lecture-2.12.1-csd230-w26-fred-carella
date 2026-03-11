import { useState, useEffect } from 'react';
import { Routes, Route } from 'react-router';
import Navbar from './NavBar';
import Home from './Home';
import Book from './Book';
import BookForm from './BookForm';
import Magazine from './Magazine';
import MagazineForm from './MagazineForm';
import Cart from './Cart';
import Login from './pages/Login';       // NEW
import Logout from './pages/Logout';     // NEW
import { ProtectedRoute } from './routes/ProtectedRoute'; // NEW
import { useAuth } from './provider/authProvider';        // NEW
import api from './api/axiosConfig';     // NEW
import './App.css';
function App() {
    const { token } = useAuth(); // Get auth state
    const [books, setBooks] = useState([]);
    const[magazines, setMagazines] = useState([]);
    const [cartCount, setCartCount] = useState(0);
    const [loading, setLoading] = useState(true);
    useEffect(() => {
        // If no token exists, don't attempt to fetch secure data
        if (!token) {
            setLoading(false);
            return;
        }
        const loadInitialData = async () => {
            try {
                const [booksRes, magsRes, cartRes] = await Promise.all([
                    api.get('/books'),
                    api.get('/magazines'),
                    api.get('/cart')
                ]);
                setBooks(booksRes.data);
                setMagazines(magsRes.data);
                setCartCount(cartRes.data.products.length);
            } catch (err) {
                console.error("Failed to load data", err);
            } finally {
                setLoading(false);
            }
        };
        loadInitialData();
    }, [token]); // Re-run fetch when token changes (i.e., on login)
    const handleAddToCart = async (productId) => { /* keeping your existing code */
        try {
            const res = await api.post(`/cart/add/${productId}`);
            setCartCount(res.data.products.length);
            alert("Added to cart!");
        } catch (err) {
            alert("Error adding to cart");
        }
    };
    const handleDeleteBook = async (id) => { /* keeping your existing code */
        if (!window.confirm("Delete book?")) return;
        await api.delete(`/books/${id}`);
        setBooks(books.filter(b => b.id !== id));
    };
    const handleUpdateBook = async (id, data) => { /* keeping your existing code */
        const res = await api.put(`/books/${id}`, data);
        setBooks(books.map(b => b.id === id ? res.data : b));
    };
    if (loading) return <h2>Loading Bookstore...</h2>;
    return (
        <div className="app-container">
            {/* Only show Navbar if logged in */}
            {token && <Navbar cartCount={cartCount} />}
            
            <Routes>
                {/* 1. PUBLIC ROUTES */}
                <Route path="/login" element={<Login />} />
                
                {/* 2. PROTECTED ROUTES */}
                <Route element={<ProtectedRoute />}>
                    <Route path="/" element={<Home />} />
                    <Route path="/inventory" element={
                        <div className="book-list">
                            <h1>Books</h1>
                            {books.map(b => (
                                <Book key={b.id} {...b}
                                      onDelete={handleDeleteBook}
                                      onUpdate={handleUpdateBook}
                                      onAddToCart={handleAddToCart} />
                            ))}
                        </div>
                    } />
                    <Route path="/magazines" element={
                        <div className="magazine-list">
                            <h1>Magazines</h1>
                            {magazines.map(m => (
                                <Magazine key={m.id} {...m}
                                          onAddToCart={handleAddToCart}
                                          onDelete={(id) => api.delete(`/magazines/${id}`).then(() => setMagazines(magazines.filter(mag => mag.id !== id)))}
                                          onUpdate={(id, data) => api.put(`/magazines/${id}`, data).then(res => setMagazines(magazines.map(mag => mag.id === id ? res.data : mag)))}
                                />
                            ))}
                        </div>
                    } />
                    <Route path="/cart" element={<Cart api={api} onCartChange={(count) => setCartCount(count)} />} />
                    <Route path="/add" element={<BookForm onBookAdded={(b) => setBooks([...books, b])} api={api} />} />
                    <Route path="/add-magazine" element={<MagazineForm onMagazineAdded={(m) => setMagazines([...magazines, m])} api={api} />} />
                    <Route path="/logout" element={<Logout />} />
                </Route>
            </Routes>
        </div>
    );
}
export default App;
