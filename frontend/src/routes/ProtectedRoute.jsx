import { Navigate, Outlet } from "react-router";
import { useAuth } from "../provider/authProvider";
export const ProtectedRoute = () => {
    const { token } = useAuth();
    // Check if the user is authenticated
    if (!token) {
        // If not authenticated, redirect to the login page
        return <Navigate to="/login" replace />;
    }
    // If authenticated, render the child routes (e.g., Home, Inventory)
    return <Outlet />;
};
