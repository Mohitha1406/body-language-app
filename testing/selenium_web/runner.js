const DriverManager = require('./helpers/driverManager');
const ExcelReporter = require('./helpers/excelReporter');
const config = require('./config');

const runAuthTests = require('./test_cases/01_auth_e2e.test.js');
const runNavigationTests = require('./test_cases/02_navigation_e2e.test.js');
const runCameraAnalysisTests = require('./test_cases/03_camera_analysis_e2e.test.js');

async function executeSeleniumWebE2E() {
  console.log(`\n======================================================`);
  console.log(`🚀 Starting ConfidAI Selenium Web E2E Test Suite`);
  console.log(`======================================================`);

  const dm = new DriverManager();
  const reporter = new ExcelReporter(config.reportPath);

  try {
    console.log(`[DriverManager] Initializing Selenium Browser (${config.browser})...`);
    await dm.buildDriver();

    // Execute Test Suites
    await runAuthTests(dm, reporter);
    await runNavigationTests(dm, reporter);
    await runCameraAnalysisTests(dm, reporter);

  } catch (globalErr) {
    console.error('Fatal execution error during Selenium test suite:', globalErr);
  } finally {
    console.log(`\n[DriverManager] Closing browser session...`);
    await dm.quit();

    // Generate Excel Report
    console.log(`\n[ExcelReporter] Compiling Excel Analysis Report...`);
    await reporter.generateReport();
    console.log(`🎉 Selenium Web E2E Test Execution Completed Successfully!\n`);
  }
}

executeSeleniumWebE2E();
