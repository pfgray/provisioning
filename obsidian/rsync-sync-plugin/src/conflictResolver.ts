import { Notice } from 'obsidian';
import { logger } from './logger';
import type { SyncSettings } from './settings';

export class ConflictResolver {
  constructor(private settings: SyncSettings) {}

  async resolve(conflicts: string[]): Promise<void> {
    if (conflicts.length === 0) {
      return;
    }

    logger.warn(`Detected ${conflicts.length} conflicts:`, conflicts);

    switch (this.settings.conflictStrategy) {
      case 'newest':
        await this.resolveByTimestamp(conflicts);
        break;
      case 'server':
        await this.resolvePreferServer(conflicts);
        break;
      case 'client':
        await this.resolvePreferClient(conflicts);
        break;
      default:
        await this.notifyUser(conflicts);
    }
  }

  private async resolveByTimestamp(conflicts: string[]): Promise<void> {
    logger.info('Using "newest wins" strategy for conflicts');
    // rclone bisync with --conflict-resolve newer handles this automatically
    // Just log the conflicts that were resolved
    new Notice(`Resolved ${conflicts.length} conflicts using newest version`);
  }

  private async resolvePreferServer(conflicts: string[]): Promise<void> {
    logger.info('Server wins strategy - keeping remote versions');
    new Notice(`Resolved ${conflicts.length} conflicts - keeping server version`);
    // rclone bisync with --conflict-resolve path2 handles this
  }

  private async resolvePreferClient(conflicts: string[]): Promise<void> {
    logger.info('Client wins strategy - keeping local versions');
    new Notice(`Resolved ${conflicts.length} conflicts - keeping local version`);
    // rclone bisync with --conflict-resolve path1 handles this
  }

  private async notifyUser(conflicts: string[]): Promise<void> {
    const message = `Sync conflicts detected in ${conflicts.length} files:\n${conflicts.slice(0, 5).join('\n')}${conflicts.length > 5 ? '\n...' : ''}`;
    new Notice(message, 10000);
    logger.warn(message);
  }
}
