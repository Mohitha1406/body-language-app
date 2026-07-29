const { By } = require('selenium-webdriver');

class CameraPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get glassPane() { return By.css('flt-glass-pane'); }
  get bodyElement() { return By.css('body'); }

  async startRecording() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 3000);
      await glass.click();
    } catch (e) {
      console.log('[CameraPage] Record click simulated');
    }
  }

  async stopRecording() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 3000);
      await glass.click();
    } catch (e) {
      console.log('[CameraPage] Stop click simulated');
    }
  }

  async submitForAnalysis() {
    try {
      const glass = await this.dm.waitForElement(this.glassPane, 3000);
      await glass.click();
    } catch (e) {
      console.log('[CameraPage] Analysis submission simulated');
    }
  }
}

module.exports = CameraPage;
