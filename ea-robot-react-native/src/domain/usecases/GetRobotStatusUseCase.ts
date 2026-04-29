import { Robot } from '../entities/Robot';
import { RobotRepository } from '../repositories/RobotRepository';

export class GetRobotStatusUseCase {
  constructor(private repository: RobotRepository) {}

  async execute(): Promise<Robot> {
    return await this.repository.getStatus();
  }
}
