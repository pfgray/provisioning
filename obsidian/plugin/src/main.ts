import { Plugin, Notice } from 'obsidian';
import { SyncManager } from './syncManager';
import { FileWatcher } from './fileWatcher';
import { SyncSettingTab, DEFAULT_SETTINGS, SyncSettings } from './settings';
import { logger } from './logger';

export default class RsyncSyncPlugin extends Plugin {
  settings: SyncSettings;
  syncManager: SyncManager;
  fileWatcher: FileWatcher;
  periodicPullInterval: number | null = null;

  async onload() {
    logger.info('Loading Rsync Sync plugin');

    await this.loadSettings();

    // Initialize sync manager with vault path
    const vaultPath = (this.app.vault.adapter as any).basePath;
    this.syncManager = new SyncManager(this.settings, vaultPath);

    // Initialize file watcher
    this.fileWatcher = new FileWatcher(
      this.app.vault,
      this.syncManager,
      this.settings
    );

    // Initial pull on startup if enabled
    if (this.settings.enabled && this.settings.syncOnStartup) {
      logger.info('Performing initial sync on startup');
      this.performInitialSync();
    }

    // Start file watching
    this.fileWatcher.start();

    // Register periodic pull
    this.registerPeriodicPull();

    // Add settings tab
    this.addSettingTab(new SyncSettingTab(this.app, this));

    // Add manual sync command
    this.addCommand({
      id: 'manual-sync',
      name: 'Trigger Manual Sync',
      callback: async () => {
        logger.info('Manual sync triggered');
        new Notice('Starting sync...');
        try {
          await this.syncManager.fullSync();
          new Notice('Sync completed successfully');
        } catch (error) {
          new Notice(`Sync failed: ${(error as Error).message}`);
        }
      }
    });

    // Add debug toggle command
    this.addCommand({
      id: 'toggle-debug',
      name: 'Toggle Debug Logging',
      callback: () => {
        const currentDebug = localStorage.getItem('rsync-sync-debug') === 'true';
        if (currentDebug) {
          logger.disableDebug();
          new Notice('Debug logging disabled');
        } else {
          logger.enableDebug();
          new Notice('Debug logging enabled - check Developer Console');
        }
      }
    });

    // Add status bar item
    const statusBarItem = this.addStatusBarItem();
    statusBarItem.setText('Rsync Sync: Ready');

    logger.info('Rsync Sync plugin loaded');
  }

  async onunload() {
    logger.info('Unloading Rsync Sync plugin');

    // Cleanup file watcher
    this.fileWatcher.cleanup();

    // Clear periodic pull interval
    if (this.periodicPullInterval) {
      window.clearInterval(this.periodicPullInterval);
    }
  }

  async loadSettings() {
    this.settings = Object.assign({}, DEFAULT_SETTINGS, await this.loadData());
  }

  async saveSettings() {
    await this.saveData(this.settings);

    // Restart periodic pull if interval changed
    if (this.periodicPullInterval) {
      window.clearInterval(this.periodicPullInterval);
      this.registerPeriodicPull();
    }
  }

  private async performInitialSync() {
    try {
      await this.syncManager.pull();
      new Notice('Initial sync completed');
    } catch (error) {
      logger.error('Initial sync failed:', error);
      new Notice(`Initial sync failed: ${(error as Error).message}`);
    }
  }

  private registerPeriodicPull() {
    if (!this.settings.enabled) {
      logger.info('Periodic pull disabled (sync disabled)');
      return;
    }

    const intervalMs = this.settings.pullIntervalMinutes * 60 * 1000;
    logger.info(`Registering periodic pull every ${this.settings.pullIntervalMinutes} minutes`);

    this.periodicPullInterval = window.setInterval(async () => {
      logger.info('Periodic pull triggered');
      try {
        await this.syncManager.pull();
      } catch (error) {
        logger.error('Periodic pull failed:', error);
      }
    }, intervalMs);

    // Register for cleanup
    this.registerInterval(this.periodicPullInterval);
  }
}
