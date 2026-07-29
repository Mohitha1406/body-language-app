const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const config = require('../config');
const fs = require('fs');
const path = require('path');
const http = require('http');

class DriverManager {
  constructor() {
    this.driver = null;
    this.server = null;
  }

  async ensureServerRunning() {
    if (config.baseUrl.includes('localhost') || config.baseUrl.includes('127.0.0.1')) {
      const port = 8080;
      const buildDir = path.resolve(__dirname, '../../../build/web');
      
      if (fs.existsSync(buildDir)) {
        try {
          const serveStatic = require('serve-handler');
          this.server = http.createServer((request, response) => {
            return serveStatic(request, response, { public: buildDir });
          });
          this.server.listen(port);
          console.log(`[DriverManager] Started local static server at http://localhost:${port}`);
        } catch (e) {
          console.log(`[DriverManager] Local static server note: ${e.message}`);
        }
      }
    }
  }

  async buildDriver() {
    await this.ensureServerRunning();

    const options = new chrome.Options();
    if (config.headless) {
      options.addArguments('--headless=new');
    }
    options.addArguments('--no-sandbox');
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--window-size=1280,800');
    options.addArguments('--use-fake-ui-for-media-stream');
    options.addArguments('--allow-insecure-localhost');

    this.driver = await new Builder()
      .forBrowser(config.browser)
      .setChromeOptions(options)
      .build();

    await this.driver.manage().setTimeouts({ implicit: config.implicitTimeoutMs });
    return this.driver;
  }

  async navigateTo(url = config.baseUrl) {
    console.log(`[DriverManager] Navigating browser to: ${url}`);
    await this.driver.get(url);
    // Allow Flutter Web engine initialization time
    await this.driver.sleep(3000);
  }

  async waitForElement(locator, timeout = config.explicitTimeoutMs) {
    return await this.driver.wait(until.elementLocated(locator), timeout);
  }

  async waitForVisible(locator, timeout = config.explicitTimeoutMs) {
    const el = await this.waitForElement(locator, timeout);
    await this.driver.wait(until.elementIsVisible(el), timeout);
    return el;
  }

  async takeScreenshot(filename) {
    const screenshotsDir = path.resolve('./reports/screenshots');
    if (!fs.existsSync(screenshotsDir)) {
      fs.mkdirSync(screenshotsDir, { recursive: true });
    }
    const imageBuffer = await this.driver.takeScreenshot();
    const filePath = path.join(screenshotsDir, `${filename}_${Date.now()}.png`);
    fs.writeFileSync(filePath, imageBuffer, 'base64');
    return filePath;
  }

  async quit() {
    if (this.driver) {
      await this.driver.quit();
      this.driver = null;
    }
    if (this.server) {
      this.server.close();
      this.server = null;
    }
  }
}

module.exports = DriverManager;
