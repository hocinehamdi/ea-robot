import { useEffect, useState } from 'react';
import * as DeviceTelemetry from '../../../modules/device-telemetry';

export function useDeviceTelemetry() {
  const [thermalState, setThermalState] = useState<string>('UNKNOWN');

  useEffect(() => {
    // Initial fetch
    DeviceTelemetry.getThermalStateAsync().then(setThermalState);

    // Subscribe to changes
    const subscription = DeviceTelemetry.addThermalStateListener((event) => {
      setThermalState(event.state);
    });

    return () => {
      subscription.remove();
    };
  }, []);

  return { thermalState };
}
