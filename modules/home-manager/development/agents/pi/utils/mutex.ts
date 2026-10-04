export class Mutex {
  private locked = false;
  private queue: (() => void)[] = [];

  async acquire(): Promise<() => void> {
    if (!this.locked) {
      this.locked = true;
      return () => this.release();
    }

    await new Promise<void>((resolve) => {
      this.queue.push(resolve);
    });

    return () => this.release();
  }

  private release() {
    const next = this.queue.shift();

    if (next) {
      next();
    } else {
      this.locked = false;
    }
  }
}
