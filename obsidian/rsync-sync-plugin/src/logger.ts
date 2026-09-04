export class Logger {
  private prefix = '[Rsync Sync]';
  private debugEnabled = false;

  constructor() {
    // Check localStorage for debug flag
    if (typeof localStorage !== 'undefined') {
      this.debugEnabled = localStorage.getItem('rsync-sync-debug') === 'true';
    }
  }

  info(message: string, ...args: any[]): void {
    console.log(`${this.prefix} ${message}`, ...args);
  }

  error(message: string, ...args: any[]): void {
    console.error(`${this.prefix} ERROR: ${message}`, ...args);
  }

  warn(message: string, ...args: any[]): void {
    console.warn(`${this.prefix} WARN: ${message}`, ...args);
  }

  debug(message: string, ...args: any[]): void {
    if (this.debugEnabled) {
      console.debug(`${this.prefix} DEBUG: ${message}`, ...args);
    }
  }

  enableDebug(): void {
    this.debugEnabled = true;
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('rsync-sync-debug', 'true');
    }
    console.log(`${this.prefix} Debug mode enabled`);
  }

  disableDebug(): void {
    this.debugEnabled = false;
    if (typeof localStorage !== 'undefined') {
      localStorage.removeItem('rsync-sync-debug');
    }
    console.log(`${this.prefix} Debug mode disabled`);
  }
}

export const logger = new Logger();
