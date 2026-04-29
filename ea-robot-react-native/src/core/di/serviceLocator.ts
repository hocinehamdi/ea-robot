import { AxiosRobotRepository } from '../../data/repositories/AxiosRobotRepository';
import { CommandQueue } from '../network/CommandQueue';
import { GetRobotStatusUseCase } from '../../domain/usecases/GetRobotStatusUseCase';
import { ConnectRobotUseCase } from '../../domain/usecases/ConnectRobotUseCase';
import { DisconnectRobotUseCase } from '../../domain/usecases/DisconnectRobotUseCase';
import { MoveRobotUseCase } from '../../domain/usecases/MoveRobotUseCase';
import { StopRobotUseCase } from '../../domain/usecases/StopRobotUseCase';

// Concrete Implementation (Data Layer)
const repository = new AxiosRobotRepository();

// Infrastructure
const commandQueue = new CommandQueue(
  async (type) => {
    switch (type) {
      case 'move': return await repository.move();
      case 'stop': return await repository.stop();
      case 'connect': return await repository.connect();
      case 'disconnect': return await repository.disconnect();
      default: return false;
    }
  },
  (type, success) => {
    console.log(`[DI] Command ${type} was processed successfully from queue`);
  }
);

// Domain Layer (Use Cases)
export const getRobotStatusUseCase = new GetRobotStatusUseCase(repository);
export const connectRobotUseCase = new ConnectRobotUseCase(repository);
export const disconnectRobotUseCase = new DisconnectRobotUseCase(repository);
export const moveRobotUseCase = new MoveRobotUseCase(repository, commandQueue);
export const stopRobotUseCase = new StopRobotUseCase(repository, commandQueue);

// Repository Export (for Telemetry subscription)
export const robotRepository = repository;
