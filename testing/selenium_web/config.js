require('dotenv').config();

module.exports = {
  baseUrl: process.env.WEB_BASE_URL || 'https://confidai-b469a.web.app',
  backendUrl: process.env.BACKEND_URL || 'https://body-language-app.onrender.com',
  browser: process.env.BROWSER || 'chrome',
  headless: process.env.HEADLESS === 'true',
  implicitTimeoutMs: 10000,
  explicitTimeoutMs: 15000,
  reportPath: './reports/Selenium_Web_E2E_Test_Report.xlsx',
  testUser: {
    name: 'QA Test User',
    email: 'qatest@confidai.com',
    password: 'Password123!',
    phone: '1234567890'
  }
};
