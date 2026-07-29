class MobileHomePage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get appBarTitle() { return '~App Bar Title'; }
  get recordSessionBtn() { return '~Start Video Recording Button'; }
  get historyTab() { return '~History Bottom Tab'; }
  get profileTab() { return '~Profile Bottom Tab'; }
  get drawerButton() { return '~Open Drawer Navigation'; }

  async navigateToHistory() {
    if (!this.driver) return;
    const el = await this.driver.$(this.historyTab);
    await el.click();
  }

  async navigateToProfile() {
    if (!this.driver) return;
    const el = await this.driver.$(this.profileTab);
    await el.click();
  }

  async startRecordSession() {
    if (!this.driver) return;
    const el = await this.driver.$(this.recordSessionBtn);
    await el.click();
  }
}

module.exports = MobileHomePage;
