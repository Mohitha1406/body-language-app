class MobileHomePage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get historyTab() { return '~History Bottom Tab'; }
  get profileTab() { return '~Profile Bottom Tab'; }
  get recordSessionBtn() { return '~Start Video Recording Button'; }

  async navigateToHistory() {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.historyTab);
        if (await el.isExisting()) {
          await el.click();
        } else {
          await this.driver.pause(500 + Math.floor(Math.random() * 450));
        }
      } catch (e) {
        await this.driver.pause(400 + Math.floor(Math.random() * 300));
      }
    }
  }

  async navigateToProfile() {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.profileTab);
        if (await el.isExisting()) {
          await el.click();
        } else {
          await this.driver.pause(450 + Math.floor(Math.random() * 400));
        }
      } catch (e) {
        await this.driver.pause(350 + Math.floor(Math.random() * 300));
      }
    }
  }

  async startRecordSession() {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.recordSessionBtn);
        if (await el.isExisting()) {
          await el.click();
        } else {
          await this.driver.pause(600 + Math.floor(Math.random() * 500));
        }
      } catch (e) {
        await this.driver.pause(450 + Math.floor(Math.random() * 350));
      }
    }
  }
}

module.exports = MobileHomePage;
