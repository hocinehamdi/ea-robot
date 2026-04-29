import { MoveRobotUseCase } from './MoveRobotUseCase';
import { RobotRepository } from '../repositories/RobotRepository';
import { CommandQueue } from '../../core/network/CommandQueue';

describe('MoveRobotUseCase', () => {
  let useCase: MoveRobotUseCase;
  let mockRepo: jest.Mocked<RobotRepository>;
  let mockQueue: jest.Mocked<CommandQueue>;

  beforeEach(() => {
    mockRepo = {
      move: jest.fn(),
      stop: jest.fn(),
      getStatus: jest.fn(),
      connect: jest.fn(),
      disconnect: jest.fn(),
      subscribeToTelemetry: jest.fn(),
    } as any;

    mockQueue = {
      addCommand: jest.fn(),
    } as any;

    useCase = new MoveRobotUseCase(mockRepo, mockQueue);
  });

  it('should return true when repository.move() succeeds', async () => {
    mockRepo.move.mockResolvedValue(true);
    
    const result = await useCase.execute();
    
    expect(result).toBe(true);
    expect(mockRepo.move).toHaveBeenCalled();
    expect(mockQueue.addCommand).not.toHaveBeenCalled();
  });

  it('should add to queue and throw error when repository.move() fails', async () => {
    mockRepo.move.mockRejectedValue(new Error('Network error'));
    
    await expect(useCase.execute()).rejects.toThrow('Connection lost. Command queued for retry.');
    expect(mockQueue.addCommand).toHaveBeenCalledWith('move');
  });
});
