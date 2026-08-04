const DriverManager = require('./helpers/driverManager');
const ExcelReporter = require('./helpers/excelReporter');
const config = require('./config');

const runUnitAndLogicTests = require('./test_cases/01_unit_and_logic.test.js');
const runFunctionalWebTests = require('./test_cases/02_functional_web.test.js');
const runValidationFormTests = require('./test_cases/03_validation_forms.test.js');
const runUiUxDesignTests = require('./test_cases/04_ui_ux_design.test.js');
const runVulnerabilitySecurityTests = require('./test_cases/05_vulnerability_security.test.js');
const runLoadPerformanceTests = require('./test_cases/06_load_performance.test.js');

async function executeSeleniumWebE2E() {
  console.log(`\n======================================================`);
  console.log(`🚀 Starting ConfidAI Selenium Web E2E Test Suite (300 Tests)`);
  console.log(`======================================================`);

  const dm = new DriverManager();
  const reporter = new ExcelReporter(config.reportPath);

  try {
    console.log(`[DriverManager] Initializing Selenium Browser (${config.browser})...`);
    await dm.buildDriver();

    // Execute 300 Selenium Web Test Cases
    await runUnitAndLogicTests(dm, reporter);
    await runFunctionalWebTests(dm, reporter);
    await runValidationFormTests(dm, reporter);
    await runUiUxDesignTests(dm, reporter);
    await runVulnerabilitySecurityTests(dm, reporter);
    await runLoadPerformanceTests(dm, reporter);

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
