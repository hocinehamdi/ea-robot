import { RobotRepository } from '../repositories/RobotRepository';
import { CommandQueue } from '../../core/network/CommandQueue';

export class StopRobotUseCase {
  constructor(
    private repository: RobotRepository,
    private commandQueue: CommandQueue
  ) {}

  async execute(): Promise<boolean> {
    try {
      return await this.repository.stop();
    } catch {
      console.log('[UseCase] Stop failed, adding to offline queue');
      this.commandQueue.addCommand('stop');
      throw new Error('Connection lost. Command queued for retry.');
    }
  }
}
