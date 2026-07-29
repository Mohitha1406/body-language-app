const { By } = require('selenium-webdriver');

class HistoryPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get historyListItems() { return By.xpath("//*[contains(@class,'card') or contains(text(),'Score') or contains(text(),'Session')]"); }
  get emptyStateText() { return By.xpath("//*[contains(text(),'No sessions recorded') or contains(text(),'History is empty')]"); }
  get refreshButton() { return By.xpath("//button[contains(@aria-label,'Refresh') or contains(.,'Refresh')]"); }

  async getSessionCount() {
    try {
      const items = await this.driver.findElements(this.historyListItems);
      return items.length;
    } catch (e) {
      return 0;
    }
  }

  async isListEmpty() {
    try {
      const el = await this.dm.waitForVisible(this.emptyStateText, 3000);
      return (await el.getText()).length > 0;
    } catch (e) {
      return false;
    }
  }
}

module.exports = HistoryPage;
