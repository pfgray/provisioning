import { Notice } from 'obsidian';
import { CommandExecutor } from './commandExecutor';
import { ConflictResolver } from './conflictResolver';
import { SyncState } from './syncState';
import { logger } from './logger';
import type { SyncSettings } from './settings';

export class SyncManager {
  private executor: CommandExecutor;
  private conflictResolver: ConflictResolver;
  private state: SyncState;

  constructor(
    private settings: SyncSettings,
    private vaultPath: string
  ) {
    this.executor = new CommandExecutor();
    this.conflictResolver = new ConflictResolver(settings);
    this.state = new SyncState();
  }

  async pull(): Promise<void> {
    if (!this.settings.enabled) {
      logger.debug('Sync disabled, skipping pull');
      return;
    }

    if (!this.state.canSync()) {
      logger.debug('Sync already in progress, skipping pull');
      return;
    }

    try {
      this.state.startSync();
      logger.info('Starting pull from remote');

      const command = this.buildBisyncCommand();
      const result = await this.executor.execute(command);

      if (result.conflicts.length > 0) {
        await this.conflictResolver.resolve(result.conflicts);
      }

      logger.info('Pull completed successfully');
      this.state.endSync();
    } catch (error) {
      logger.error('Pull failed:', error);
      this.state.endSync(error as Error);
      new Notice(`Sync failed: ${(error as Error).message}`);
      throw error;
    }
  }

  async push(changedFiles: string[]): Promise<void> {
    if (!this.settings.enabled) {
      logger.debug('Sync disabled, skipping push');
      return;
    }

    if (!this.state.canSync()) {
      logger.debug('Sync already in progress, skipping push');
      return;
    }

    try {
      this.state.startSync();
      logger.info(`Starting push of ${changedFiles.length} files`);

      // For bisync, we just run the sync command which handles both directions
      const command = this.buildBisyncCommand();
      const result = await this.executor.execute(command);

      if (result.conflicts.length > 0) {
        await this.conflictResolver.resolve(result.conflicts);
      }

      logger.info('Push completed successfully');
      this.state.endSync();
    } catch (error) {
      logger.error('Push failed:', error);
      this.state.endSync(error as Error);
      new Notice(`Sync failed: ${(error as Error).message}`);
      throw error;
    }
  }

  async fullSync(): Promise<void> {
    logger.info('Starting full sync');
    await this.pull();
  }

  private buildBisyncCommand(): string {
    const remotePath = `obsidian-remote:${this.settings.remotePath}`;

    // Build conflict resolution flag based on strategy
    const conflictResolve = this.getConflictResolveFlag();

    // Build exclude flags
    const excludeFlags = this.settings.excludePatterns
      .map(pattern => `--exclude "${pattern}"`)
      .join(' ');

    // Check if this is first sync (no state files exist)
    const resyncFlag = this.needsResync() ? '--resync' : '';

    const command = `${this.settings.rclonePath} bisync \
      "${this.vaultPath}" \
      "${remotePath}" \
      --create-empty-src-dirs \
      --compare size,modtime,checksum \
      ${conflictResolve} \
      --resilient \
      --recover \
      --max-delete 10 \
      ${excludeFlags} \
      ${resyncFlag} \
      --verbose`;

    return command;
  }

  private needsResync(): boolean {
    // Check if bisync state files exist
    const fs = require('fs');
    const path = require('path');
    const os = require('os');

    // Bisync stores state in platform-specific cache directory
    const homeDir = os.homedir();
    const platform = os.platform();
    const cacheDir = platform === 'darwin'
      ? path.join(homeDir, 'Library', 'Caches', 'rclone', 'bisync')
      : path.join(homeDir, '.cache', 'rclone', 'bisync');

    // Build expected state file names (same format rclone uses)
    const vaultName = this.vaultPath.replace(/\//g, '_').replace(/^_/, '');
    const remoteName = `obsidian-remote_${this.settings.remotePath.replace(/\//g, '_').replace(/^_/, '')}`;
    const stateFile1 = path.join(cacheDir, `${vaultName}..${remoteName}.path1.lst`);
    const stateFile2 = path.join(cacheDir, `${vaultName}..${remoteName}.path2.lst`);

    const exists = fs.existsSync(stateFile1) && fs.existsSync(stateFile2);

    if (!exists) {
      logger.info('First sync detected, will use --resync flag');
    }

    return !exists;
  }

  private getConflictResolveFlag(): string {
    switch (this.settings.conflictStrategy) {
      case 'newest':
        return '--conflict-resolve newer';
      case 'server':
        return '--conflict-resolve path2'; // path2 is remote
      case 'client':
        return '--conflict-resolve path1'; // path1 is local
      default:
        return '--conflict-resolve newer';
    }
  }

  getState(): SyncState {
    return this.state;
  }
}
