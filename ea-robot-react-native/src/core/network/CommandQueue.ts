import NetInfo from '@react-native-community/netinfo';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface Command {
  id: string;
  type: 'move' | 'stop' | 'connect' | 'disconnect';
  timestamp: number;
}

const QUEUE_STORAGE_KEY = '@robot_command_queue';

export class CommandQueue {
  private queue: Command[] = [];
  private isProcessing = false;
  private onCommandProcessed?: (type: string, success: boolean) => void;
  private executor?: (type: Command['type']) => Promise<any>;

  constructor(
    executor: (type: Command['type']) => Promise<any>,
    onCommandProcessed?: (type: string, success: boolean) => void
  ) {
    this.executor = executor;
    this.onCommandProcessed = onCommandProcessed;
    this.loadQueue();
    this.setupNetworkListener();
  }

  private async loadQueue() {
    try {
      const savedQueue = await AsyncStorage.getItem(QUEUE_STORAGE_KEY);
      if (savedQueue) {
        this.queue = JSON.parse(savedQueue);
        console.log(`[Queue] Loaded ${this.queue.length} pending commands`);
        this.processQueue();
      }
    } catch (e) {
      console.error('[Queue] Failed to load queue', e);
    }
  }

  private async saveQueue() {
    try {
      await AsyncStorage.setItem(QUEUE_STORAGE_KEY, JSON.stringify(this.queue));
    } catch (e) {
      console.error('[Queue] Failed to save queue', e);
    }
  }

  private setupNetworkListener() {
    NetInfo.addEventListener(state => {
      if (state.isConnected && state.isInternetReachable) {
        console.log('[Queue] Network restored, processing queue...');
        this.processQueue();
      }
    });
  }

  public async addCommand(type: Command['type']) {
    const command: Command = {
      id: Math.random().toString(36).substring(7),
      type,
      timestamp: Date.now(),
    };
    
    this.queue.push(command);
    await this.saveQueue();
    console.log(`[Queue] Added command: ${type}`);
    
    this.processQueue();
  }

  private async processQueue() {
    if (this.isProcessing || this.queue.length === 0) return;

    const netInfo = await NetInfo.fetch();
    if (!netInfo.isConnected || !netInfo.isInternetReachable) {
      console.log('[Queue] Still offline, waiting for connection...');
      return;
    }

    this.isProcessing = true;
    
    while (this.queue.length > 0) {
      const command = this.queue[0];
      console.log(`[Queue] Retrying command: ${command.type}`);

      try {
        // We'll pass the actual execution to a handler or import the repository
        // For simplicity in this structure, we'll assume a global handler is set
        const success = await this.executor?.(command.type);
        
        if (success !== undefined) {
          this.queue.shift();
          await this.saveQueue();
          this.onCommandProcessed?.(command.type, true);
        } else {
          // If it fails with a 500, we might want to retry later
          console.log(`[Queue] Command ${command.type} failed, keeping in queue`);
          break;
        }
      } catch (e) {
        console.error(`[Queue] Error processing command ${command.type}`, e);
        break;
      }
    }

    this.isProcessing = false;
  }
}
