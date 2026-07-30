const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const config = require('../config');
const fs = require('fs');
const path = require('path');
const http = require('http');
const generateY4M = require('../../test_assets/create_y4m');

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
          const mimeTypes = {
            '.html': 'text/html',
            '.js': 'text/javascript',
            '.css': 'text/css',
            '.json': 'application/json',
            '.png': 'image/png',
            '.jpg': 'image/jpg',
            '.wasm': 'application/wasm',
            '.otf': 'font/otf',
            '.ttf': 'font/ttf',
            '.woff': 'font/woff',
            '.woff2': 'font/woff2'
          };

          this.server = http.createServer((req, res) => {
            let reqUrl = req.url.split('?')[0];
            let filePath = path.join(buildDir, reqUrl === '/' ? 'index.html' : reqUrl);
            if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
              filePath = path.join(buildDir, 'index.html');
            }
            const ext = path.extname(filePath).toLowerCase();
            const contentType = mimeTypes[ext] || 'application/octet-stream';

            fs.readFile(filePath, (err, content) => {
              if (err) {
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
              } else {
                res.writeHead(200, { 'Content-Type': contentType });
                res.end(content, 'utf-8');
              }
            });
          });

          await new Promise((resolve) => {
            this.server.listen(port, () => {
              console.log(`[DriverManager] Started local static server at http://localhost:${port}`);
              resolve();
            });
          });
        } catch (e) {
          console.log(`[DriverManager] Local static server note: ${e.message}`);
        }
      }
    }
  }

  async buildDriver() {
    await this.ensureServerRunning();

    // Ensure sample_video.y4m exists
    const y4mPath = path.resolve(__dirname, '../../test_assets/sample_video.y4m');
    if (!fs.existsSync(y4mPath)) {
      generateY4M();
    }

    const options = new chrome.Options();
    if (config.headless) {
      options.addArguments('--headless=new');
    }
    options.addArguments('--no-sandbox');
    options.addArguments('--disable-dev-shm-usage');
    options.addArguments('--window-size=1280,800');
    options.addArguments('--use-fake-ui-for-media-stream');
    options.addArguments('--use-fake-device-for-media-stream');
    options.addArguments(`--use-file-for-fake-video-capture=${y4mPath}`);
    options.addArguments('--allow-insecure-localhost');
    options.addArguments('--autoplay-policy=no-user-gesture-required');

    this.driver = await new Builder()
      .forBrowser(config.browser)
      .setChromeOptions(options)
      .build();

    await this.driver.manage().setTimeouts({ implicit: config.implicitTimeoutMs });
    return this.driver;
  }

  async enableSemantics() {
    console.log('[DriverManager] Enabling Flutter Web Semantics / Accessibility Tree...');
    try {
      await this.driver.executeScript(`
        const placeholder = document.querySelector('flt-semantics-placeholder') ||
                            document.querySelector('button[aria-label*="accessibility"]') ||
                            document.querySelector('flt-glass-pane')?.shadowRoot?.querySelector('flt-semantics-placeholder');
        if (placeholder) {
          placeholder.click();
        }
        if (window.flutterConfiguration && typeof window.flutterConfiguration.enableSemantics === 'function') {
          window.flutterConfiguration.enableSemantics();
        }
      `);

      const placeholders = await this.driver.findElements(By.css('flt-semantics-placeholder'));
      if (placeholders.length > 0) {
        await placeholders[0].click().catch(() => {});
      }

      await this.driver.sleep(1500);
    } catch (e) {
      console.log(`[DriverManager] Note when enabling semantics: ${e.message}`);
    }
  }

  async navigateTo(url = config.baseUrl) {
    console.log(`[DriverManager] Navigating browser to: ${url}`);
    await this.driver.get(url);
    await this.driver.sleep(3000);
    await this.enableSemantics();
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
