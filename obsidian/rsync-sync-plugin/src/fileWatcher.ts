import { TAbstractFile, Vault } from 'obsidian';
import { logger } from './logger';
import type { SyncManager } from './syncManager';
import type { SyncSettings } from './settings';

export class FileWatcher {
  private debounceTimer: NodeJS.Timeout | null = null;
  private pendingChanges: Set<string> = new Set();

  constructor(
    private vault: Vault,
    private syncManager: SyncManager,
    private settings: SyncSettings
  ) {}

  start(): void {
    if (!this.settings.syncOnFileChange) {
      logger.info('File watching disabled by settings');
      return;
    }

    logger.info('Starting file watcher');

    // Register vault events
    this.vault.on('create', this.handleChange.bind(this));
    this.vault.on('modify', this.handleChange.bind(this));
    this.vault.on('delete', this.handleChange.bind(this));
    this.vault.on('rename', this.handleRename.bind(this));
  }

  private handleChange(file: TAbstractFile): void {
    // Ignore system files and folders
    if (this.shouldIgnore(file.path)) {
      return;
    }

    logger.debug('File changed:', file.path);
    this.pendingChanges.add(file.path);
    this.debouncedSync();
  }

  private handleRename(file: TAbstractFile, oldPath: string): void {
    if (this.shouldIgnore(file.path) && this.shouldIgnore(oldPath)) {
      return;
    }

    logger.debug('File renamed:', oldPath, '->', file.path);
    this.pendingChanges.add(file.path);
    this.pendingChanges.add(oldPath);
    this.debouncedSync();
  }

  private debouncedSync(): void {
    // Clear existing timer
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    // Set new timer
    const debounceMs = this.settings.debounceSeconds * 1000;
    this.debounceTimer = setTimeout(async () => {
      if (this.pendingChanges.size > 0) {
        logger.info(`Triggering sync for ${this.pendingChanges.size} changed files`);
        const changes = Array.from(this.pendingChanges);
        this.pendingChanges.clear();

        try {
          await this.syncManager.push(changes);
        } catch (error) {
          logger.error('Failed to sync changes:', error);
        }
      }
    }, debounceMs);
  }

  private shouldIgnore(path: string): boolean {
    // Check against exclude patterns
    for (const pattern of this.settings.excludePatterns) {
      // Simple glob matching
      const regex = new RegExp(
        '^' + pattern.replace(/\*/g, '.*').replace(/\?/g, '.') + '$'
      );
      if (regex.test(path)) {
        return true;
      }
    }

    // Ignore system files
    if (path.startsWith('.obsidian/workspace') ||
        path.startsWith('.trash/') ||
        path.startsWith('.git/')) {
      return true;
    }

    return false;
  }

  cleanup(): void {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
  }
}
