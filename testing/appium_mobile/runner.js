const AppiumDriverManager = require('./helpers/driverManager');
const AppiumExcelReporter = require('./helpers/excelReporter');
const config = require('./config');

const runMobileAuthTests = require('./test_cases/01_mobile_auth_e2e.test.js');
const runMobileNavigationTests = require('./test_cases/02_mobile_navigation_e2e.test.js');

async function executeAppiumMobileE2E() {
  console.log(`\n======================================================`);
  console.log(`📱 Starting ConfidAI Appium Mobile E2E Test Suite`);
  console.log(`======================================================`);

  const dm = new AppiumDriverManager();
  const reporter = new AppiumExcelReporter(config.reportPath);

  try {
    console.log(`[AppiumDriverManager] Initializing Mobile Session...`);
    await dm.buildDriver('android');

    // Execute Mobile Test Suites
    await runMobileAuthTests(dm, reporter);
    await runMobileNavigationTests(dm, reporter);

  } catch (globalErr) {
    console.error('Fatal execution error during Appium mobile test suite:', globalErr);
  } finally {
    console.log(`\n[AppiumDriverManager] Cleaning up Appium session...`);
    await dm.quit();

    // Generate Mobile Excel Report
    console.log(`\n[AppiumExcelReporter] Compiling Mobile Excel Analysis Report...`);
    await reporter.generateReport();
    console.log(`🎉 Appium Mobile E2E Test Execution Completed Successfully!\n`);
  }
}

executeAppiumMobileE2E();
