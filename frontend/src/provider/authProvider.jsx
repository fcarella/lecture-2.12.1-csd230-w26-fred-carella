import { createContext, useContext, useMemo, useState } from "react";

const AuthContext = createContext();

const AuthProvider = ({ children }) => {
    const [token, setToken_] = useState(localStorage.getItem("token"));

    // Helper: Decodes the JWT payload to extract roles
    const getRolesFromToken = (t) => {
        if (!t) return [];
        try {
            const base64Url = t.split('.')[1];
            const base64 = base64Url.replace('-', '+').replace('_', '/');
            const payload = JSON.parse(window.atob(base64));
            return payload.roles || [];
        } catch (e) {
            console.error("Failed to decode token", e);
            return [];
        }
    };

    const roles = useMemo(() => getRolesFromToken(token), [token]);

    const setToken = (newToken) => {
        setToken_(newToken);
        if (newToken) {
            localStorage.setItem("token", newToken);
        } else {
            localStorage.removeItem("token");
        }
    };

    const contextValue = useMemo(
        () => ({
            token,
            roles,
            isAdmin: roles.includes("ROLE_ADMIN"),
            setToken,
        }),
        [token, roles]
    );

    return (
        <AuthContext.Provider value={contextValue}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
export default AuthProvider;