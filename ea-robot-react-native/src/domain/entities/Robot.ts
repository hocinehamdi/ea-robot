export interface Robot {
  connected: boolean;
  battery: number;
  moving: boolean;
  thermalState?: 'NOMINAL' | 'FAIR' | 'SERIOUS' | 'CRITICAL';
  deviceThermalState?: string;
}

export interface RobotTelemetry extends Robot {
  timestamp: number;
}
