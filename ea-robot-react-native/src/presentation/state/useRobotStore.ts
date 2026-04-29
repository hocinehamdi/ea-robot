import { create } from 'zustand';
import { Robot } from '../../domain/entities/Robot';
import {
  getRobotStatusUseCase,
  connectRobotUseCase,
  disconnectRobotUseCase,
  moveRobotUseCase,
  stopRobotUseCase,
} from '../../core/di/serviceLocator';

export interface QueuedCommand {
  id: string;
  label: string;
  method: string;
  path: string;
  status: 'pending' | 'processing' | 'failed' | 'success';
  timestamp: Date;
}

interface RobotState {
  robot: Robot | null;
  loading: boolean;
  error: string | null;
  commandQueue: QueuedCommand[];
  
  fetchStatus: () => Promise<void>;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  move: () => Promise<void>;
  stop: () => Promise<void>;
  updateFromTelemetry: (data: Robot) => void;
  setDeviceThermalState: (state: string) => void;
  clearQueue: () => void;
}

export const useRobotStore = create<RobotState>((set, get) => ({
  robot: null,
  loading: false,
  error: null,
  commandQueue: [],

  fetchStatus: async () => {
    set({ loading: true, error: null });
    try {
      const robot = await getRobotStatusUseCase.execute();
      set({ robot, loading: false });
    } catch (err: any) {
      set({ error: err.message, loading: false });
    }
  },

  connect: async () => {
    set({ loading: true, error: null });
    try {
      const robot = await connectRobotUseCase.execute();
      set({ robot, loading: false });
    } catch (err: any) {
      set({ error: err.message, loading: false });
    }
  },

  disconnect: async () => {
    set({ loading: true, error: null });
    try {
      const robot = await disconnectRobotUseCase.execute();
      set({ robot, loading: false });
    } catch (err: any) {
      set({ error: err.message, loading: false });
    }
  },

  move: async () => {
    const commandId = Math.random().toString(36).substring(7);
    const newCommand: QueuedCommand = {
      id: commandId,
      label: 'MOVE ROBOT',
      method: 'POST',
      path: '/move',
      status: 'processing',
      timestamp: new Date(),
    };

    set((state) => ({ commandQueue: [newCommand, ...state.commandQueue] }));

    try {
      const moving = await moveRobotUseCase.execute();
      set((state) => ({
        robot: state.robot ? { ...state.robot, moving } : null,
        commandQueue: state.commandQueue.map(c => 
          c.id === commandId ? { ...c, status: 'success' as const } : c
        )
      }));
    } catch (err: any) {
      set((state) => ({ 
        error: err.message,
        commandQueue: state.commandQueue.map(c => 
          c.id === commandId ? { ...c, status: 'failed' as const } : c
        )
      }));
    }
  },

  stop: async () => {
    const commandId = Math.random().toString(36).substring(7);
    const newCommand: QueuedCommand = {
      id: commandId,
      label: 'STOP ROBOT',
      method: 'POST',
      path: '/stop',
      status: 'processing',
      timestamp: new Date(),
    };

    set((state) => ({ commandQueue: [newCommand, ...state.commandQueue] }));

    try {
      const moving = await stopRobotUseCase.execute();
      set((state) => ({
        robot: state.robot ? { ...state.robot, moving } : null,
        commandQueue: state.commandQueue.map(c => 
          c.id === commandId ? { ...c, status: 'success' as const } : c
        )
      }));
    } catch (err: any) {
      set((state) => ({ 
        error: err.message,
        commandQueue: state.commandQueue.map(c => 
          c.id === commandId ? { ...c, status: 'failed' as const } : c
        )
      }));
    }
  },

  updateFromTelemetry: (data: Robot) => {
    set({ robot: data });
  },

  setDeviceThermalState: (state: string) => {
    set((s) => ({
      robot: s.robot ? { ...s.robot, deviceThermalState: state } : null,
    }));
  },
  clearQueue: () => {
    set({ commandQueue: [] });
  },
}));
