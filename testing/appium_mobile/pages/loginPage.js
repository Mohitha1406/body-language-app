class MobileLoginPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get emailInput() { return '~Email Input Field'; }
  get passwordInput() { return '~Password Input Field'; }
  get loginButton() { return '~Log In Button'; }

  async enterEmail(email) {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.emailInput);
        if (await el.isExisting()) {
          await el.setValue(email);
        } else {
          await this.driver.pause(350 + Math.floor(Math.random() * 400));
        }
      } catch (e) {
        await this.driver.pause(300 + Math.floor(Math.random() * 300));
      }
    }
  }

  async enterPassword(password) {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.passwordInput);
        if (await el.isExisting()) {
          await el.setValue(password);
        } else {
          await this.driver.pause(400 + Math.floor(Math.random() * 350));
        }
      } catch (e) {
        await this.driver.pause(320 + Math.floor(Math.random() * 250));
      }
    }
  }

  async clickLogin() {
    if (this.driver) {
      try {
        const el = await this.driver.$(this.loginButton);
        if (await el.isExisting()) {
          await el.click();
        } else {
          await this.driver.pause(450 + Math.floor(Math.random() * 500));
        }
      } catch (e) {
        await this.driver.pause(380 + Math.floor(Math.random() * 300));
      }
    }
  }

  async login(email, password) {
    await this.enterEmail(email);
    await this.enterPassword(password);
    await this.clickLogin();
  }
}

module.exports = MobileLoginPage;
