export class SyncState {
  private _isInProgress = false;
  private _lastSyncTime: number | null = null;
  private _lastError: Error | null = null;

  get isInProgress(): boolean {
    return this._isInProgress;
  }

  get lastSyncTime(): number | null {
    return this._lastSyncTime;
  }

  get lastError(): Error | null {
    return this._lastError;
  }

  startSync(): void {
    this._isInProgress = true;
    this._lastError = null;
  }

  endSync(error?: Error): void {
    this._isInProgress = false;
    this._lastSyncTime = Date.now();
    if (error) {
      this._lastError = error;
    }
  }

  canSync(): boolean {
    return !this._isInProgress;
  }
}
