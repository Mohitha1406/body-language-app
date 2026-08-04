const fs = require('fs');
const path = require('path');

function appendToGhaSummary(results = []) {
  const summaryFile = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryFile) return;

  const total = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  const passRate = total > 0 ? ((passed / total) * 100).toFixed(2) : '0';

  const markdown = `
### 📱 Appium Mobile E2E Test Execution Summary

| Metric Description | Value |
| :--- | :--- |
| **Total Test Cases Executed** | **${total}** |
| **Total Passed** | **${passed}** ✅ |
| **Total Failed** | **${failed}** ❌ |
| **Overall Pass Rate** | **${passRate}%** |
| **Execution Timestamp** | ${new Date().toUTCString()} |

---
`;

  try {
    fs.appendFileSync(summaryFile, markdown, 'utf-8');
    console.log('[generateSummary] Successfully appended summary to GITHUB_STEP_SUMMARY');
  } catch (e) {
    console.log(`[generateSummary Warning]: Could not append to summary: ${e.message}`);
  }
}

module.exports = appendToGhaSummary;
