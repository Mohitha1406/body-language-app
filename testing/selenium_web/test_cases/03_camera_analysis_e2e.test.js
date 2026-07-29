const HomePage = require('../pages/homePage');
const CameraPage = require('../pages/cameraPage');

async function runCameraAnalysisTests(dm, reporter) {
  const suiteName = 'AI Body Language Analysis E2E Suite';
  const homePage = new HomePage(dm);
  const cameraPage = new CameraPage(dm);

  console.log(`\n========================================`);
  console.log(` Running Suite: ${suiteName}`);
  console.log(`========================================`);

  // Test 1: Open Camera Session Screen
  let t1Start = Date.now();
  try {
    await homePage.clickStartSession();
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AI-001',
      title: 'Open Camera Session Recording Screen',
      status: 'PASS',
      durationMs: Date.now() - t1Start,
      notes: 'Camera viewport opened with media permission handling.'
    });
    console.log('  ✔ [PASS] TC-AI-001: Open Camera Session Recording Screen');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AI-001',
      title: 'Open Camera Session Recording Screen',
      status: 'FAIL',
      durationMs: Date.now() - t1Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-AI-001: Open Camera Session Recording Screen');
  }

  // Test 2: AI Posture Analysis Submission Workflow
  let t2Start = Date.now();
  try {
    await cameraPage.startRecording();
    await new Promise(r => setTimeout(r, 2000));
    await cameraPage.stopRecording();
    await cameraPage.submitForAnalysis();

    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AI-002',
      title: 'Record Video & Submit for AI Posture Analysis',
      status: 'PASS',
      durationMs: Date.now() - t2Start,
      notes: 'Video recorded and payload sent to FastAPI /analyze endpoint.'
    });
    console.log('  ✔ [PASS] TC-AI-002: Record Video & Submit for AI Posture Analysis');
  } catch (err) {
    reporter.addResult({
      suite: suiteName,
      testId: 'TC-AI-002',
      title: 'Record Video & Submit for AI Posture Analysis',
      status: 'FAIL',
      durationMs: Date.now() - t2Start,
      error: err.message
    });
    console.log('  ✖ [FAIL] TC-AI-002: Record Video & Submit for AI Posture Analysis');
  }
}

module.exports = runCameraAnalysisTests;
