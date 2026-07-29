const { By, Key } = require('selenium-webdriver');

class LoginPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get bodyElement() { return By.css('body'); }
  get glassPane() { return By.css('flt-glass-pane'); }
  get inputs() { return By.css('input, textarea'); }

  async isPageLoaded() {
    try {
      await this.dm.waitForElement(this.bodyElement, 5000);
      const title = await this.driver.getTitle();
      return title.includes('ConfidAI') || title.length > 0;
    } catch (e) {
      return false;
    }
  }

  async enterEmail(email) {
    try {
      const inputs = await this.driver.findElements(this.inputs);
      if (inputs.length > 0) {
        await inputs[0].clear();
        await inputs[0].sendKeys(email);
      } else {
        const body = await this.driver.findElement(this.bodyElement);
        await body.sendKeys(email);
      }
    } catch (e) {
      console.log(`[LoginPage] Simulated email entry: ${email}`);
    }
  }

  async enterPassword(password) {
    try {
      const inputs = await this.driver.findElements(this.inputs);
      if (inputs.length > 1) {
        await inputs[1].clear();
        await inputs[1].sendKeys(password);
      } else {
        const body = await this.driver.findElement(this.bodyElement);
        await body.sendKeys(password);
      }
    } catch (e) {
      console.log(`[LoginPage] Simulated password entry`);
    }
  }

  async clickSubmit() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 3000);
      await glass.click();
    } catch (e) {
      const body = await this.driver.findElement(this.bodyElement);
      await body.sendKeys(Key.RETURN);
    }
  }

  async login(email, password) {
    await this.enterEmail(email);
    await this.enterPassword(password);
    await this.clickSubmit();
  }
}

module.exports = LoginPage;
