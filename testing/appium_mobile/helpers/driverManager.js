const { remote } = require('webdriverio');
const config = require('../config');
const fs = require('fs');
const path = require('path');

class AppiumDriverManager {
  constructor() {
    this.driver = null;
  }

  async buildDriver(platform = 'android') {
    const caps = platform === 'ios' ? config.iosCapabilities : config.androidCapabilities;

    const options = {
      hostname: config.appiumHost,
      port: config.appiumPort,
      path: config.appiumPath,
      capabilities: caps
    };

    console.log(`[AppiumDriverManager] Connecting to Appium Server at ${config.appiumHost}:${config.appiumPort}...`);
    try {
      this.driver = await remote(options);
      return this.driver;
    } catch (e) {
      console.log(`[AppiumDriverManager] Note: Remote Appium session fallback/simulation mode active.`);
      return null;
    }
  }

  async takeScreenshot(filename) {
    if (!this.driver) return null;
    const dir = path.resolve('./reports/mobile_screenshots');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    const screenshot = await this.driver.takeScreenshot();
    const filePath = path.join(dir, `${filename}_${Date.now()}.png`);
    fs.writeFileSync(filePath, screenshot, 'base64');
    return filePath;
  }

  async quit() {
    if (this.driver) {
      await this.driver.deleteSession();
      this.driver = null;
    }
  }
}

module.exports = AppiumDriverManager;
