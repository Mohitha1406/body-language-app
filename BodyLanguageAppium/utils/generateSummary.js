const fs = require('fs');
const path = require('path');

function appendToGhaSummary(results = []) {
  const summaryFile = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryFile) {
    console.log('[generateSummary Note]: GITHUB_STEP_SUMMARY environment variable not set (running locally).');
    return;
  }

  const total = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  const passRate = total > 0 ? ((passed / total) * 100).toFixed(2) : '0';

  const categoryMap = {};
  results.forEach(r => {
    const cat = r.category || 'General';
    if (!categoryMap[cat]) categoryMap[cat] = { total: 0, passed: 0, failed: 0 };
    categoryMap[cat].total++;
    if (r.status === 'PASS') categoryMap[cat].passed++;
    else categoryMap[cat].failed++;
  });

  let catRows = '';
  Object.keys(categoryMap).forEach(cat => {
    const c = categoryMap[cat];
    const rate = ((c.passed / c.total) * 100).toFixed(2) + '%';
    catRows += `| **${cat}** | ${c.total} | ${c.passed} | ${c.failed} | ${rate} |\n`;
  });

  const markdown = `
## 📱 Appium Mobile E2E Test Execution Summary

| KPI Metric Description | Metric Value |
| :--- | :--- |
| 🧪 **Total Test Cases Executed** | **${total}** |
| ✅ **Total Passed Test Cases** | **${passed}** |
| ❌ **Total Failed Test Cases** | **${failed}** |
| 📈 **Overall Suite Pass Rate** | **${passRate}%** |
| 🕒 **Execution Timestamp** | ${new Date().toUTCString()} |

### 📊 Mobile Test Category Breakdown

| Category Name | Total Executed | Passed | Failed | Category Pass Rate |
| :--- | :--- | :--- | :--- | :--- |
${catRows}

---
> 📥 **Artifacts Ready for Download**: Download \`Appium_Mobile_E2E_Test_Report.xlsx\` and \`execution-report.html\` below.
`;

  try {
    fs.appendFileSync(summaryFile, markdown, 'utf-8');
    console.log('[generateSummary] Successfully appended summary table to GITHUB_STEP_SUMMARY');
  } catch (e) {
    console.log(`[generateSummary Error]: ${e.message}`);
  }
}

module.exports = appendToGhaSummary;
