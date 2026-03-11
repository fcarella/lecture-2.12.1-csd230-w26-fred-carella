import { useState } from 'react';

function BookForm({ onBookAdded, api }) {
    const [title, setTitle] = useState('');
    const [author, setAuthor] = useState('');
    const [price, setPrice] = useState(0);

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const res = await api.post('/books', { title, author, price, copies: 10 });
            alert("Book Saved!");
            onBookAdded(res.data);
            setTitle(''); setAuthor(''); setPrice(0);
        } catch (err) {
            alert("Save failed.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-style">
            <h3>Add New Book</h3>
            <input type="text" placeholder="Title" value={title} onChange={(e) => setTitle(e.target.value)} required />
            <input type="text" placeholder="Author" value={author} onChange={(e) => setAuthor(e.target.value)} required />
            <input type="number" placeholder="Price" value={price} onChange={(e) => setPrice(e.target.value)} required />
            <button type="submit">Save Book</button>
        </form>
    );
}

export default BookForm;

