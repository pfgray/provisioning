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

    // Clean up stale lock files from crashed syncs
    this.cleanupStaleLock();
  }

  // Remove lock files older than 2 minutes (likely from crashed/suspended syncs)
  // Public so it can be called on window focus (e.g., after wake from sleep)
  cleanupStaleLock(): void {
    const fs = require('fs');
    const path = require('path');
    const os = require('os');

    const homeDir = os.homedir();
    const platform = os.platform();
    const cacheDir = platform === 'darwin'
      ? path.join(homeDir, 'Library', 'Caches', 'rclone', 'bisync')
      : path.join(homeDir, '.cache', 'rclone', 'bisync');

    const vaultName = this.vaultPath.replace(/\//g, '_').replace(/^_/, '');
    const remotePathEncoded = this.settings.remotePath.replace(/\//g, '_');
    const remoteName = `obsidian-remote_${remotePathEncoded}`;
    const lockFile = path.join(cacheDir, `${vaultName}..${remoteName}.lck`);

    try {
      if (fs.existsSync(lockFile)) {
        const stats = fs.statSync(lockFile);
        const ageMinutes = (Date.now() - stats.mtimeMs) / (1000 * 60);

        if (ageMinutes > 2) {
          logger.info(`Removing stale lock file (${Math.round(ageMinutes)} minutes old)`);
          fs.unlinkSync(lockFile);
        } else {
          logger.debug(`Lock file exists but is recent (${Math.round(ageMinutes)} minutes old), leaving it`);
        }
      }
    } catch (error) {
      logger.error('Failed to check/cleanup lock file:', error);
    }
  }

  // Build rclone config as environment variables
  // This avoids needing a config file that rclone might try to modify
  private getRcloneEnv(): Record<string, string> {
    return {
      RCLONE_CONFIG_OBSIDIAN_REMOTE_TYPE: 'sftp',
      RCLONE_CONFIG_OBSIDIAN_REMOTE_HOST: this.settings.remoteHost,
      RCLONE_CONFIG_OBSIDIAN_REMOTE_USER: this.settings.remoteUser,
      RCLONE_CONFIG_OBSIDIAN_REMOTE_SHELL_TYPE: 'unix',
      // key_file is intentionally omitted to use SSH agent
    };
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
      const result = await this.executor.execute(command, { env: this.getRcloneEnv() });

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
      const result = await this.executor.execute(command, { env: this.getRcloneEnv() });

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

  async forceResync(): Promise<void> {
    if (!this.state.canSync()) {
      logger.debug('Sync already in progress, skipping force resync');
      return;
    }

    try {
      this.state.startSync();
      logger.info('Starting force resync (resetting baseline)');

      const command = this.buildBisyncCommand(true); // Force --resync flag
      const result = await this.executor.execute(command, { env: this.getRcloneEnv() });

      if (result.conflicts.length > 0) {
        await this.conflictResolver.resolve(result.conflicts);
      }

      logger.info('Force resync completed successfully');
      this.state.endSync();
    } catch (error) {
      logger.error('Force resync failed:', error);
      this.state.endSync(error as Error);
      new Notice(`Force resync failed: ${(error as Error).message}`);
      throw error;
    }
  }

  private buildBisyncCommand(forceResync: boolean = false): string {
    const remotePath = `obsidian-remote:${this.settings.remotePath}`;

    // Build conflict resolution flag based on strategy
    const conflictResolve = this.getConflictResolveFlag();

    // Build exclude flags
    const excludeFlags = this.settings.excludePatterns
      .map(pattern => `--exclude "${pattern}"`)
      .join(' ');

    // Check if this is first sync (no state files exist) or force resync requested
    const resyncFlag = (forceResync || this.needsResync()) ? '--resync' : '';

    const command = `${this.settings.rclonePath} bisync \
      "${this.vaultPath}" \
      "${remotePath}" \
      --create-empty-src-dirs \
      ${conflictResolve} \
      --resilient \
      --recover \
      --max-delete ${this.settings.maxDelete} \
      --check-access \
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
    // Format: {path1-with-slashes-as-underscores}..{remote}_{path2-with-slashes-as-underscores}.pathN.lst
    const vaultName = this.vaultPath.replace(/\//g, '_').replace(/^_/, '');
    const remotePathEncoded = this.settings.remotePath.replace(/\//g, '_');
    const remoteName = `obsidian-remote_${remotePathEncoded}`;
    const stateFile1 = path.join(cacheDir, `${vaultName}..${remoteName}.path1.lst`);
    const stateFile2 = path.join(cacheDir, `${vaultName}..${remoteName}.path2.lst`);

    const exists = fs.existsSync(stateFile1) && fs.existsSync(stateFile2);

    if (!exists) {
      logger.info('First sync detected, will use --resync flag');
      logger.debug(`Looking for: ${stateFile1}`);
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
