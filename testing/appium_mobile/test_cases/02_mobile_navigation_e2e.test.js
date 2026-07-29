const MobileHomePage = require('../pages/homePage');

async function runMobileNavigationTests(dm, reporter) {
  const suiteName = 'Appium Mobile Navigation & Camera E2E Suite';
  const homePage = new MobileHomePage(dm);

  console.log(`\n========================================`);
  console.log(` Running Suite: ${suiteName}`);
  console.log(`========================================`);

  // Test 1: Mobile Bottom Tab Navigation to Session History
  let t1Start = Date.now();
  try {
    await homePage.navigateToHistory();
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-NAV-001',
      title: 'Mobile App History Tab Touch Navigation',
      status: 'PASS',
      durationMs: Date.now() - t1Start,
      notes: 'Switched to Session History tab on mobile device.'
    });
    console.log('  ✔ [PASS] TC-MOB-NAV-001: Mobile App History Tab Touch Navigation');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-NAV-001',
      title: 'Mobile App History Tab Touch Navigation',
      status: 'FAIL',
      durationMs: Date.now() - t1Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-MOB-NAV-001: Mobile App History Tab Touch Navigation');
  }

  // Test 2: Mobile Camera Stream & Posture Analysis Launch
  let t2Start = Date.now();
  try {
    await homePage.startRecordSession();
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-CAM-002',
      title: 'Mobile Camera Preview & AI Posture Analysis Trigger',
      status: 'PASS',
      durationMs: Date.now() - t2Start,
      notes: 'Native camera hardware permissions initialized.'
    });
    console.log('  ✔ [PASS] TC-MOB-CAM-002: Mobile Camera Preview & AI Posture Analysis Trigger');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-MOB-CAM-002',
      title: 'Mobile Camera Preview & AI Posture Analysis Trigger',
      status: 'FAIL',
      durationMs: Date.now() - t2Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-MOB-CAM-002: Mobile Camera Preview & AI Posture Analysis Trigger');
  }
}

module.exports = runMobileNavigationTests;
