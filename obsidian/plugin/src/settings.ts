import { App, PluginSettingTab, Setting } from 'obsidian';
import type RsyncSyncPlugin from './main';

export interface SyncSettings {
  enabled: boolean;
  rclonePath: string;
  remoteHost: string;
  remoteUser: string;
  remotePath: string;
  sshKeyPath: string;
  pullIntervalMinutes: number;
  debounceSeconds: number;
  conflictStrategy: 'newest' | 'server' | 'client';
  excludePatterns: string[];
  syncOnStartup: boolean;
  syncOnFileChange: boolean;
}

export const DEFAULT_SETTINGS: SyncSettings = {
  enabled: true,
  rclonePath: '/usr/bin/rclone',
  remoteHost: '',
  remoteUser: 'obsidian-sync',
  remotePath: '',
  sshKeyPath: '',
  pullIntervalMinutes: 5,
  debounceSeconds: 5,
  conflictStrategy: 'newest',
  excludePatterns: ['.trash', '.git', '.obsidian/workspace*'],
  syncOnStartup: true,
  syncOnFileChange: true,
};

export class SyncSettingTab extends PluginSettingTab {
  plugin: RsyncSyncPlugin;

  constructor(app: App, plugin: RsyncSyncPlugin) {
    super(app, plugin);
    this.plugin = plugin;
  }

  display(): void {
    const { containerEl } = this;
    containerEl.empty();

    containerEl.createEl('h2', { text: 'Rsync Sync Settings' });

    new Setting(containerEl)
      .setName('Enable sync')
      .setDesc('Enable or disable automatic synchronization')
      .addToggle(toggle => toggle
        .setValue(this.plugin.settings.enabled)
        .onChange(async (value) => {
          this.plugin.settings.enabled = value;
          await this.plugin.saveSettings();
        }));

    containerEl.createEl('h3', { text: 'Remote Configuration' });

    new Setting(containerEl)
      .setName('Rclone path')
      .setDesc('Path to rclone binary (configured by Nix)')
      .addText(text => text
        .setValue(this.plugin.settings.rclonePath)
        .onChange(async (value) => {
          this.plugin.settings.rclonePath = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Remote host')
      .setDesc('SSH hostname or IP of sync server')
      .addText(text => text
        .setValue(this.plugin.settings.remoteHost)
        .onChange(async (value) => {
          this.plugin.settings.remoteHost = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Remote user')
      .setDesc('SSH username for sync')
      .addText(text => text
        .setValue(this.plugin.settings.remoteUser)
        .onChange(async (value) => {
          this.plugin.settings.remoteUser = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Remote path')
      .setDesc('Path to vault directory on server')
      .addText(text => text
        .setValue(this.plugin.settings.remotePath)
        .onChange(async (value) => {
          this.plugin.settings.remotePath = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('SSH key path')
      .setDesc('Path to SSH private key')
      .addText(text => text
        .setValue(this.plugin.settings.sshKeyPath)
        .onChange(async (value) => {
          this.plugin.settings.sshKeyPath = value;
          await this.plugin.saveSettings();
        }));

    containerEl.createEl('h3', { text: 'Sync Behavior' });

    new Setting(containerEl)
      .setName('Sync on startup')
      .setDesc('Pull changes when Obsidian opens')
      .addToggle(toggle => toggle
        .setValue(this.plugin.settings.syncOnStartup)
        .onChange(async (value) => {
          this.plugin.settings.syncOnStartup = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Sync on file change')
      .setDesc('Automatically push changes when files are modified')
      .addToggle(toggle => toggle
        .setValue(this.plugin.settings.syncOnFileChange)
        .onChange(async (value) => {
          this.plugin.settings.syncOnFileChange = value;
          await this.plugin.saveSettings();
        }));

    new Setting(containerEl)
      .setName('Pull interval (minutes)')
      .setDesc('How often to check for remote changes')
      .addText(text => text
        .setValue(String(this.plugin.settings.pullIntervalMinutes))
        .onChange(async (value) => {
          const num = parseInt(value);
          if (!isNaN(num) && num > 0) {
            this.plugin.settings.pullIntervalMinutes = num;
            await this.plugin.saveSettings();
          }
        }));

    new Setting(containerEl)
      .setName('Debounce delay (seconds)')
      .setDesc('Wait time after last change before syncing')
      .addText(text => text
        .setValue(String(this.plugin.settings.debounceSeconds))
        .onChange(async (value) => {
          const num = parseInt(value);
          if (!isNaN(num) && num > 0) {
            this.plugin.settings.debounceSeconds = num;
            await this.plugin.saveSettings();
          }
        }));

    new Setting(containerEl)
      .setName('Conflict resolution')
      .setDesc('How to handle conflicting changes')
      .addDropdown(dropdown => dropdown
        .addOption('newest', 'Newest wins (by modification time)')
        .addOption('server', 'Server wins (prefer remote)')
        .addOption('client', 'Client wins (prefer local)')
        .setValue(this.plugin.settings.conflictStrategy)
        .onChange(async (value: 'newest' | 'server' | 'client') => {
          this.plugin.settings.conflictStrategy = value;
          await this.plugin.saveSettings();
        }));
  }
}
