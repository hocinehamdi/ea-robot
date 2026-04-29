import { Robot } from '../entities/Robot';

export interface RobotRepository {
  getStatus(): Promise<Robot>;
  connect(): Promise<Robot>;
  disconnect(): Promise<Robot>;
  move(): Promise<boolean>;
  stop(): Promise<boolean>;
  subscribeToTelemetry(callback: (data: any) => void): () => void;
}
