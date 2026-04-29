import { RobotRepository } from '../repositories/RobotRepository';
import { CommandQueue } from '../../core/network/CommandQueue';

export class MoveRobotUseCase {
  constructor(
    private repository: RobotRepository,
    private commandQueue: CommandQueue
  ) {}

  async execute(): Promise<boolean> {
    try {
      return await this.repository.move();
    } catch {
      console.log('[UseCase] Move failed, adding to offline queue');
      this.commandQueue.addCommand('move');
      throw new Error('Connection lost. Command queued for retry.');
    }
  }
}
