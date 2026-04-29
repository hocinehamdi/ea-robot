import { Robot } from '../entities/Robot';
import { RobotRepository } from '../repositories/RobotRepository';

export class ConnectRobotUseCase {
  constructor(private repository: RobotRepository) {}

  async execute(): Promise<Robot> {
    return await this.repository.connect();
  }
}
