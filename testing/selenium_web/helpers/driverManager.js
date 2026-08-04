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
    const buildDir = path.resolve(__dirname, '../../../build/web');
    if (fs.existsSync(buildDir) && fs.existsSync(path.join(buildDir, 'index.html'))) {
      const port = 8080;
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
            console.log(`[DriverManager] Local static web server active at http://localhost:${port}`);
            config.baseUrl = `http://localhost:${port}`;
            resolve();
          });
        });
      } catch (e) {
        console.log(`[DriverManager] Local static server note: ${e.message}`);
      }
    }
  }

  async buildDriver() {
    try {
      await this.ensureServerRunning();

      const y4mPath = path.resolve(__dirname, '../../test_assets/sample_video.y4m');
      if (!fs.existsSync(y4mPath)) {
        generateY4M();
      }

      const options = new chrome.Options();
      if (config.headless || process.env.HEADLESS === 'true') {
        options.addArguments('--headless=new');
      }
      options.addArguments('--no-sandbox');
      options.addArguments('--disable-dev-shm-usage');
      options.addArguments('--disable-gpu');
      options.addArguments('--window-size=1280,800');
      options.addArguments('--use-fake-ui-for-media-stream');
      options.addArguments('--use-fake-device-for-media-stream');
      if (fs.existsSync(y4mPath)) {
        options.addArguments(`--use-file-for-fake-video-capture=${y4mPath}`);
      }
      options.addArguments('--allow-insecure-localhost');
      options.addArguments('--autoplay-policy=no-user-gesture-required');

      this.driver = await new Builder()
        .forBrowser(config.browser)
        .setChromeOptions(options)
        .build();

      await this.driver.manage().setTimeouts({ implicit: config.implicitTimeoutMs });
      return this.driver;
    } catch (err) {
      console.log(`[DriverManager Warning]: Driver initialization note: ${err.message}`);
      return null;
    }
  }

  async enableSemantics() {
    if (!this.driver) return;
    try {
      await this.driver.executeScript(`
        const placeholder = document.querySelector('flt-semantics-placeholder') ||
                            document.querySelector('button[aria-label*="accessibility"]') ||
                            document.querySelector('flt-glass-pane')?.shadowRoot?.querySelector('flt-semantics-placeholder');
        if (placeholder) {
          placeholder.click();
        }
      `);
      await this.driver.sleep(500);
    } catch (e) {}
  }

  async navigateTo(url = config.baseUrl) {
    if (!this.driver) return;
    console.log(`[DriverManager] Navigating browser to: ${url}`);
    try {
      await this.driver.get(url);
      await this.driver.sleep(1000);
      await this.enableSemantics();
    } catch (e) {
      console.log(`[DriverManager] Navigation note: ${e.message}`);
    }
  }

  async quit() {
    if (this.driver) {
      try {
        await this.driver.quit();
      } catch (e) {}
      this.driver = null;
    }
    if (this.server) {
      try {
        this.server.close();
      } catch (e) {}
      this.server = null;
    }
  }
}

module.exports = DriverManager;
