import { useState, useEffect } from 'react';

function Cart({ api, onCartChange }) {
    const [cart, setCart] = useState(null);

    const loadCart = async () => {
        const res = await api.get('/cart');
        setCart(res.data);
        onCartChange(res.data.products.length);
    };

    useEffect(() => { loadCart(); }, []);

    const handleRemove = async (id) => {
        await api.delete(`/cart/remove/${id}`);
        loadCart();
    };

    if (!cart) return <p>Loading...</p>;

    return (
        <div>
            <h1>Your Cart</h1>
            {cart.products.length === 0 ? <p>Empty</p> : (
                <table border="1" width="100%">
                    <thead><tr><th>Item</th><th>Price</th><th>Action</th></tr></thead>
                    <tbody>
                    {cart.products.map(p => (
                        <tr key={p.id}>
                            <td>{p.title || p.description}</td>
                            <td>${p.price.toFixed(2)}</td>
                            <td><button onClick={() => handleRemove(p.id)}>Remove</button></td>
                        </tr>
                    ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}

export default Cart;

