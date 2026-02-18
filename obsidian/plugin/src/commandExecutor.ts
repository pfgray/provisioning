import { Platform } from 'obsidian';
import { logger } from './logger';

export interface SyncResult {
  success: boolean;
  stdout: string;
  stderr: string;
  conflicts: string[];
}

export class SyncError extends Error {
  constructor(message: string, public stderr: string) {
    super(message);
    this.name = 'SyncError';
  }
}

export class CommandExecutor {
  async execute(command: string): Promise<SyncResult> {
    if (!Platform.isDesktop && !Platform.isDesktopApp) {
      throw new Error('This plugin requires desktop platform');
    }

    return this.executeDesktop(command);
  }

  private executeDesktop(command: string): Promise<SyncResult> {
    // Use require instead of import for Node.js modules
    // This is available in Obsidian's desktop environment
    const { exec } = require('child_process');

    logger.debug('Executing command:', command);

    return new Promise((resolve, reject) => {
      exec(
        command,
        {
          maxBuffer: 10 * 1024 * 1024, // 10MB buffer
          timeout: 300000, // 5 minute timeout
        },
        (error: any, stdout: string, stderr: string) => {
          if (error) {
            logger.error('Command failed:', error.message);
            logger.error('stderr:', stderr);
            reject(new SyncError(error.message, stderr));
          } else {
            logger.debug('Command succeeded');
            const result = this.parseOutput(stdout, stderr);
            resolve(result);
          }
        }
      );
    });
  }

  private parseOutput(stdout: string, stderr: string): SyncResult {
    // Parse rclone bisync output for conflicts
    const conflicts: string[] = [];

    // Look for conflict indicators in output
    const lines = (stdout + '\n' + stderr).split('\n');
    for (const line of lines) {
      if (line.includes('CONFLICT') || line.includes('conflict')) {
        // Extract file path from conflict message
        const match = line.match(/([^\s]+\.(md|txt|json|pdf|png|jpg))/);
        if (match) {
          conflicts.push(match[1]);
        }
      }
    }

    return {
      success: true,
      stdout,
      stderr,
      conflicts,
    };
  }
}
