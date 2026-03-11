import { useState } from "react";
import { useNavigate } from "react-router";
import { useAuth } from "../provider/authProvider";
import api from "../api/axiosConfig";
const Login = () => {
    const { setToken } = useAuth();
    const navigate = useNavigate();
    
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            // Call the Spring Boot AuthController
            const res = await api.post("/auth/login", { email, password });
            
            // Save the JWT to context
            setToken(res.data.token);
            
            // Redirect to home page
            navigate("/", { replace: true });
        } catch (err) {
            setError("Invalid credentials. Please try again.");
        }
    };
    return (
        <div style={{ textAlign: "center", marginTop: "50px" }}>
            <h2>Sign In to Bookstore Admin</h2>
            {error && <p style={{ color: "red" }}>{error}</p>}
            
            <form onSubmit={handleLogin} style={{ display: "inline-block", textAlign: "left" }}>
                <div style={{ marginBottom: "10px" }}>
                    <label>Username:</label><br/>
                    <input type="text" value={email} onChange={(e) => setEmail(e.target.value)} required />
                    <small style={{display:"block", color:"#888"}}>Hint: try 'admin'</small>
                </div>
                <div style={{ marginBottom: "10px" }}>
                    <label>Password:</label><br/>
                    <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
                </div>
                <button type="submit" style={{ width: "100%" }}>Login</button>
            </form>
        </div>
    );
};
export default Login;
