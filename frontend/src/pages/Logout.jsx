import { useEffect } from "react";
import { useNavigate } from "react-router";
import { useAuth } from "../provider/authProvider";
const Logout = () => {
    const { setToken } = useAuth();
    const navigate = useNavigate();
    useEffect(() => {
        // Clear the token and redirect immediately
        setToken(null);
        navigate("/login", { replace: true });
    }, [setToken, navigate]);
    return <div>Logging out...</div>;
};
export default Logout;
