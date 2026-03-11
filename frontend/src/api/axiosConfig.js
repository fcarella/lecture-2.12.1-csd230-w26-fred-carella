import axios from 'axios';
const api = axios.create({
    baseURL: '/api/rest'
});

// Axios Interceptor: Runs right before ANY request is sent
api.interceptors.request.use(
    (config) => {
        // Dynamically grab the token right when the request fires
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

export default api;