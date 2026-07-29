const HomePage = require('../pages/homePage');

async function runNavigationTests(dm, reporter) {
  const suiteName = 'Navigation & Tabs E2E Suite';
  const homePage = new HomePage(dm);

  console.log(`\n========================================`);
  console.log(` Running Suite: ${suiteName}`);
  console.log(`========================================`);

  // Test 1: Navigation to Session History Tab
  let t1Start = Date.now();
  try {
    await homePage.navigateToHistory();
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-NAV-001',
      title: 'Navigate to Session History Tab',
      status: 'PASS',
      durationMs: Date.now() - t1Start,
      notes: 'Switched to Session History tab successfully.'
    });
    console.log('  ✔ [PASS] TC-NAV-001: Navigate to Session History Tab');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-NAV-001',
      title: 'Navigate to Session History Tab',
      status: 'FAIL',
      durationMs: Date.now() - t1Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-NAV-001: Navigate to Session History Tab');
  }

  // Test 2: Navigation to User Profile Tab
  let t2Start = Date.now();
  try {
    await homePage.navigateToProfile();
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-NAV-002',
      title: 'Navigate to User Profile Screen',
      status: 'PASS',
      durationMs: Date.now() - t2Start,
      notes: 'Switched to User Profile tab successfully.'
    });
    console.log('  ✔ [PASS] TC-NAV-002: Navigate to User Profile Screen');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-NAV-002',
      title: 'Navigate to User Profile Screen',
      status: 'FAIL',
      durationMs: Date.now() - t2Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-NAV-002: Navigate to User Profile Screen');
  }
}

module.exports = runNavigationTests;
