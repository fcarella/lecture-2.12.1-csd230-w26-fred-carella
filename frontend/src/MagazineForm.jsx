import { useState } from 'react';

function MagazineForm({ onMagazineAdded, api }) {
    const [title, setTitle] = useState('');
    const [price, setPrice] = useState('');
    const [copies, setCopies] = useState(10);
    const [orderQty, setOrderQty] = useState(100);
    const [currentIssue, setCurrentIssue] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();

        // 1. Date Formatting Safeguard
        // HTML5 datetime-local often omits seconds (e.g., 2026-03-08T15:00).
        // We append ":00" to satisfy the backend's @JsonFormat pattern.
        let formattedDate = currentIssue;
        if (formattedDate && formattedDate.length === 16) {
            formattedDate += ":00";
        }

        const newMagazine = {
            title,
            price: parseFloat(price || 0),
            copies: parseInt(copies),
            orderQty: parseInt(orderQty),
            currentIssue: formattedDate
        };

        try {
            // 2. Use the Axios instance passed from App.jsx
            const res = await api.post('/magazines', newMagazine);

            alert("Magazine successfully saved to MySQL!");

            // 3. Update the UI state in App.jsx
            onMagazineAdded(res.data);

            // 4. Reset the form
            setTitle('');
            setPrice('');
            setCopies(10);
            setOrderQty(100);
            setCurrentIssue('');
        } catch (err) {
            console.error("Save Error:", err.response?.data || err.message);
            alert("Failed to save magazine. Check console for validation errors.");
        }
    };

    return (
        <form onSubmit={handleSubmit} className="form-container" style={{ border: '2px solid purple', padding: '20px' }}>
            <h3>Add New Magazine</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <input type="text" placeholder="Magazine Title" value={title} onChange={(e) => setTitle(e.target.value)} required />

                <input type="number" step="0.01" placeholder="Price" value={price} onChange={(e) => setPrice(e.target.value)} required />

                <div style={{ display: 'flex', gap: '10px' }}>
                    <label>Copies: <input type="number" value={copies} onChange={(e) => setCopies(e.target.value)} required style={{width: '70px'}}/></label>
                    <label>Order Qty: <input type="number" value={orderQty} onChange={(e) => setOrderQty(e.target.value)} required style={{width: '70px'}}/></label>
                </div>

                <label>
                    Issue Date:
                    <input type="datetime-local" value={currentIssue} onChange={(e) => setCurrentIssue(e.target.value)} required style={{ marginLeft: '10px' }} />
                </label>

                <button type="submit" style={{ backgroundColor: 'purple', color: 'white', padding: '10px' }}>
                    Save to Database
                </button>
            </div>
        </form>
    );
}

export default MagazineForm;

