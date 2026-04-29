import { useEffect } from 'react';
import { useRobotStore } from '../state/useRobotStore';
import { robotRepository } from '../../core/di/serviceLocator';

export function useRobotTelemetry() {
  const { updateFromTelemetry } = useRobotStore();

  useEffect(() => {
    const unsubscribe = robotRepository.subscribeToTelemetry((data) => {
      updateFromTelemetry(data);
    });

    return () => {
      unsubscribe();
    };
  }, [updateFromTelemetry]);
}
