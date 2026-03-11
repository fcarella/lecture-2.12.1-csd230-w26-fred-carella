import axios from 'axios';

const api = axios.create({
    baseURL: '/api/rest'
});

// REQUEST Interceptor: Runs right before ANY request is sent
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// RESPONSE Interceptor: Handles data returning from the server
api.interceptors.response.use(
    (response) => {
        return response; // Success (2xx)
    },
    (error) => {
        // Handle 401 (Expired/Unauthorized) or 403 (Forbidden)
        if (error.response && (error.response.status === 401 || error.response.status === 403)) {
            console.warn("Security error detected. Redirecting to login...");
            
            // 1. Wipe the stale token from storage
            localStorage.removeItem('token');
            
            // 2. Hard redirect to Login with an 'expired' flag
            window.location.href = '/login?expired=true';
        }
        return Promise.reject(error);
    }
);

export default api;