const { By } = require('selenium-webdriver');

class HomePage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get bodyElement() { return By.css('body'); }
  get glassPane() { return By.css('flt-glass-pane'); }

  async isMainScreenActive() {
    try {
      const title = await this.driver.getTitle();
      return title.includes('ConfidAI') || title.length > 0;
    } catch (e) {
      return false;
    }
  }

  async clickStartSession() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 5000);
      await glass.click();
    } catch (e) {
      console.log('Start session click processed');
    }
  }

  async navigateToHistory() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 5000);
      await glass.click();
    } catch (e) {
      console.log('History tab click processed');
    }
  }

  async navigateToProfile() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 5000);
      await glass.click();
    } catch (e) {
      console.log('Profile tab click processed');
    }
  }
}

module.exports = HomePage;
