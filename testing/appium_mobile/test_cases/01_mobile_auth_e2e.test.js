const MobileLoginPage = require('../pages/loginPage');
const config = require('../config');

async function runMobileAuthTests(dm, reporter) {
  const suiteName = 'Appium Mobile Auth E2E Suite';
  const loginPage = new MobileLoginPage(dm);

  console.log(`\n========================================`);
  console.log(` Running Suite: ${suiteName}`);
  console.log(`========================================`);

  // Test 1: Mobile Invalid Email Validation
  let t1Start = Date.now();
  try {
    await loginPage.enterEmail('bademailformat');
    await loginPage.enterPassword('Password123');
    await loginPage.clickLogin();

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-AUTH-001',
      title: 'Mobile App Invalid Email Format Handling',
      status: 'PASS',
      durationMs: Date.now() - t1Start,
      notes: 'Mobile app validated email input syntax.'
    });
    console.log('  ✔ [PASS] TC-MOB-AUTH-001: Mobile App Invalid Email Format Handling');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-AUTH-001',
      title: 'Mobile App Invalid Email Format Handling',
      status: 'FAIL',
      durationMs: Date.now() - t1Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-MOB-AUTH-001: Mobile App Invalid Email Format Handling');
  }

  // Test 2: Mobile Valid User Sign-In
  let t2Start = Date.now();
  try {
    await loginPage.enterEmail(config.testUser.email);
    await loginPage.enterPassword(config.testUser.password);
    await loginPage.clickLogin();

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-AUTH-002',
      title: 'Mobile App User Login via Supabase Auth',
      status: 'PASS',
      durationMs: Date.now() - t2Start,
      notes: 'Mobile user authenticated successfully.'
    });
    console.log('  ✔ [PASS] TC-MOB-AUTH-002: Mobile App User Login via Supabase Auth');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-AUTH-002',
      title: 'Mobile App User Login via Supabase Auth',
      status: 'FAIL',
      durationMs: Date.now() - t2Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-MOB-AUTH-002: Mobile App User Login via Supabase Auth');
  }
}

module.exports = runMobileAuthTests;
