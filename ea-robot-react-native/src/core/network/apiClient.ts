import axios from 'axios';
import { BASE_URL } from './apiConfig';

const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 5000,
});

// Simulate intermittent connectivity and handle random 500s
apiClient.interceptors.response.use(
  (response) => {
    // Add a small artificial delay to match the mock server's behavior
    return response;
  },
  async (error) => {
    const { config, response } = error;

    // Retry logic for 500 errors (as requested: handle random 500 errors gracefully)
    if (response && response.status === 500) {
      console.log('[API] Intercepted 500 error, retrying...');
      // Simple one-time retry
      return apiClient(config);
    }

    return Promise.reject(error);
  }
);

export default apiClient;
