import { EventEmitter, requireNativeModule, type EventSubscription } from 'expo-modules-core';

// Load the native module directly in this file to avoid resolution issues with nested files
let DeviceTelemetryModule: any = null;
try {
  DeviceTelemetryModule = requireNativeModule('DeviceTelemetry');
} catch (e) {
  // console.warn('DeviceTelemetry native module not found. Falling back to mock.');
}

// Create a mock if the native module is not available
const mockModule = {
  getThermalStateAsync: async () => 'NOMINAL',
  addListener: () => {},
  removeListeners: () => {},
};

const moduleToUse = DeviceTelemetryModule || mockModule;

export async function getThermalStateAsync(): Promise<string> {
  try {
    return await moduleToUse.getThermalStateAsync();
  } catch (e) {
    return 'UNKNOWN';
  }
}

// Initialize emitter with the native module or a mock
const emitter = new EventEmitter(moduleToUse);

export function addThermalStateListener(listener: (event: { state: string }) => void): EventSubscription {
  try {
    return emitter.addListener('onThermalStateChange', listener);
  } catch (e) {
    // Return a dummy subscription if it fails
    return { remove: () => {} } as EventSubscription;
  }
}

