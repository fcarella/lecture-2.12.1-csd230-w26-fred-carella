import { Link } from 'react-router';
function Navbar({ cartCount }) {
    return (
        <nav className="navbar">
            <Link to="/">🏠 Home</Link>
            <Link to="/inventory">📚 Books</Link>
            <Link to="/magazines">📰 Magazines</Link>
            <Link to="/cart">🛒 Cart ({cartCount})</Link>
            <Link to="/add">➕ Add Book</Link>
            <Link to="/add-magazine">➕ Add Magazine</Link>
            <Link to="/logout" style={{ color: "#ff4444", marginLeft: "auto" }}>🚪 Logout</Link>
        </nav>
    );
}
export default Navbar;
