import apiClient from '../../core/network/apiClient';
import { TELEMETRY_URL } from '../../core/network/apiConfig';
import EventSource from 'react-native-sse';
import { Robot } from '../../domain/entities/Robot';
import { RobotRepository } from '../../domain/repositories/RobotRepository';

export class AxiosRobotRepository implements RobotRepository {
  async getStatus(): Promise<Robot> {
    const response = await apiClient.get<Robot>('/status');
    return response.data;
  }

  async connect(): Promise<Robot> {
    const response = await apiClient.post<{ message: string; status: Robot }>('/connect');
    return response.data.status;
  }

  async disconnect(): Promise<Robot> {
    const response = await apiClient.post<{ message: string; status: Robot }>('/disconnect');
    return response.data.status;
  }

  async move(): Promise<boolean> {
    const response = await apiClient.post<{ moving: boolean }>('/move');
    return response.data.moving;
  }

  async stop(): Promise<boolean> {
    const response = await apiClient.post<{ moving: boolean }>('/stop');
    return response.data.moving;
  }

  subscribeToTelemetry(callback: (data: any) => void): () => void {
    const eventSource = new EventSource(TELEMETRY_URL);

    eventSource.addEventListener('message', (event) => {
      if (event.data) {
        const data = JSON.parse(event.data);
        callback(data);
      }
    });

    eventSource.addEventListener('error', (error) => {
      console.error('[SSE] Telemetry error:', error);
    });

    return () => {
      eventSource.close();
    };
  }
}
