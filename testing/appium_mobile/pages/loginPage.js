class MobileLoginPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  // Appium Android & iOS Locators (Accessibility IDs & Resource IDs)
  get emailInput() { return '~Email Input Field'; }
  get passwordInput() { return '~Password Input Field'; }
  get loginButton() { return '~Log In Button'; }
  get signUpTab() { return '~Sign Up Toggle Tab'; }
  get nameInput() { return '~Full Name Input Field'; }

  async enterEmail(email) {
    if (!this.driver) return;
    const el = await this.driver.$(this.emailInput);
    await el.setValue(email);
  }

  async enterPassword(password) {
    if (!this.driver) return;
    const el = await this.driver.$(this.passwordInput);
    await el.setValue(password);
  }

  async clickLogin() {
    if (!this.driver) return;
    const el = await this.driver.$(this.loginButton);
    await el.click();
  }

  async login(email, password) {
    await this.enterEmail(email);
    await this.enterPassword(password);
    await this.clickLogin();
  }
}

module.exports = MobileLoginPage;
