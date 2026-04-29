import { AxiosRobotRepository } from './AxiosRobotRepository';
import apiClient from '../../core/network/apiClient';
import MockAdapter from 'axios-mock-adapter';

const mock = new MockAdapter(apiClient);

describe('AxiosRobotRepository', () => {
  let repository: AxiosRobotRepository;

  beforeEach(() => {
    repository = new AxiosRobotRepository();
    mock.reset();
  });

  it('getStatus should return robot data on success', async () => {
    const mockRobot = { connected: true, battery: 85, moving: false };
    mock.onGet('/status').reply(200, mockRobot);

    const result = await repository.getStatus();

    expect(result).toEqual(mockRobot);
    expect(mock.history.get.length).toBe(1);
  });

  it('move should return true on success', async () => {
    mock.onPost('/move').reply(200, { moving: true });

    const result = await repository.move();

    expect(result).toBe(true);
    expect(mock.history.post.length).toBe(1);
  });

  it('connect should return status on success', async () => {
    const mockStatus = { connected: true, battery: 100, moving: false };
    mock.onPost('/connect').reply(200, { message: 'Connected', status: mockStatus });

    const result = await repository.connect();

    expect(result).toEqual(mockStatus);
  });
});
