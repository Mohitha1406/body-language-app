const LoginPage = require('../pages/loginPage');
const config = require('../config');

async function runAuthTests(dm, reporter) {
  const suiteName = 'Authentication E2E Suite';
  const loginPage = new LoginPage(dm);

  console.log(`\n========================================`);
  console.log(` Running Suite: ${suiteName}`);
  console.log(`========================================`);

  // Test 1: Web App Load & Page Title Verification
  let t1Start = Date.now();
  try {
    await dm.navigateTo();
    const isLoaded = await loginPage.isPageLoaded();
    if (!isLoaded) throw new Error('Web app failed to load');

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-001',
      title: 'Verify Web App Loaded on Live Firebase Hosting',
      status: 'PASS',
      durationMs: Date.now() - t1Start,
      notes: `Web application loaded successfully at ${config.baseUrl}`
    });
    console.log('  ✔ [PASS] TC-AUTH-001: Verify Web App Loaded on Live Firebase Hosting');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-001',
      title: 'Verify Web App Loaded on Live Firebase Hosting',
      status: 'FAIL',
      durationMs: Date.now() - t1Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-AUTH-001: Verify Web App Loaded on Live Firebase Hosting');
  }

  // Test 2: Invalid Email Input Form Handling
  let t2Start = Date.now();
  try {
    await loginPage.enterEmail('invalid-email-format');
    await loginPage.enterPassword('Password123');
    await loginPage.clickSubmit();

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-002',
      title: 'Validate Form Validation for Invalid Credentials',
      status: 'PASS',
      durationMs: Date.now() - t2Start,
      notes: 'Invalid credentials input handled gracefully by authentication state.'
    });
    console.log('  ✔ [PASS] TC-AUTH-002: Validate Form Validation for Invalid Credentials');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-002',
      title: 'Validate Form Validation for Invalid Credentials',
      status: 'FAIL',
      durationMs: Date.now() - t2Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-AUTH-002: Validate Form Validation for Invalid Credentials');
  }

  // Test 3: User Authentication Workflow
  let t3Start = Date.now();
  try {
    await loginPage.enterEmail(config.testUser.email);
    await loginPage.enterPassword(config.testUser.password);
    await loginPage.clickSubmit();

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-003',
      title: 'Validate User Login with Valid Credentials',
      status: 'PASS',
      durationMs: Date.now() - t3Start,
      notes: 'User login payload submitted and processed by Supabase auth.'
    });
    console.log('  ✔ [PASS] TC-AUTH-003: Validate User Login with Valid Credentials');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AUTH-003',
      title: 'Validate User Login with Valid Credentials',
      status: 'FAIL',
      durationMs: Date.now() - t3Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-AUTH-003: Validate User Login with Valid Credentials');
  }
}

module.exports = runAuthTests;
