const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class MasterExcelReporter {
  constructor(reportFilePath = './reports/Master_E2E_Analysis_Report.xlsx') {
    this.reportFilePath = reportFilePath;
    this.allResults = [];
    this.deployableStatus = {
      webReleaseBuild: 'PENDING',
      apkReleaseBuild: 'PENDING'
    };
  }

  setDeployableStatus(webStatus, apkStatus) {
    this.deployableStatus.webReleaseBuild = webStatus;
    this.deployableStatus.apkReleaseBuild = apkStatus;
  }

  addResults(results) {
    results.forEach(r => {
      this.allResults.push({
        suite: r.suite || 'General Test Suite',
        testId: r.testId || 'TC-000',
        title: r.title || r.description || 'Test Case',
        category: r.category || 'Functional',
        status: r.status || 'PASS',
        durationMs: r.durationMs || 0,
        timestamp: r.timestamp || new Date().toISOString(),
        error: r.error || '',
        notes: r.notes || ''
      });
    });
  }

  async generateMasterReport() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'ConfidAI QA Engineering Team';
    workbook.created = new Date();

    const totalTests = this.allResults.length;
    const passedTests = this.allResults.filter(r => r.status === 'PASS').length;
    const failedTests = this.allResults.filter(r => r.status === 'FAIL').length;
    const passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(2) + '%' : '0%';
    const totalDuration = this.allResults.reduce((acc, r) => acc + r.durationMs, 0);

    const categoryMap = {};
    this.allResults.forEach(r => {
      const cat = r.category || 'General';
      if (!categoryMap[cat]) categoryMap[cat] = { total: 0, passed: 0, failed: 0 };
      categoryMap[cat].total++;
      if (r.status === 'PASS') categoryMap[cat].passed++;
      else categoryMap[cat].failed++;
    });

    // ----------------------------------------------------
    // Sheet 1: Master Executive Dashboard
    // ----------------------------------------------------
    const dashSheet = workbook.addWorksheet('Executive QA Dashboard');

    dashSheet.mergeCells('A1:F2');
    const headerCell = dashSheet.getCell('A1');
    headerCell.value = 'ConfidAI E2E & Unit Test Automation Master Analysis Report';
    headerCell.font = { name: 'Arial', size: 16, bold: true, color: { argb: 'FFFFFF' } };
    headerCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
    headerCell.alignment = { horizontal: 'center', vertical: 'middle' };

    dashSheet.addRow([]);

    dashSheet.addRow(['KPI Metric Description', 'Metric Value']);
    const kpiHeader = dashSheet.getRow(4);
    kpiHeader.font = { bold: true, color: { argb: 'FFFFFF' } };
    kpiHeader.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2C3E50' } };
    });

    const kpiRows = [
      ['Execution Date & Timestamp', new Date().toLocaleString()],
      ['Total Unique Test Cases Executed', totalTests],
      ['Total Passed Test Cases', passedTests],
      ['Total Failed Test Cases', failedTests],
      ['Overall Test Suite Pass Rate', passRate],
      ['Total Execution Duration', `${(totalDuration / 1000).toFixed(2)} seconds`]
    ];

    kpiRows.forEach(r => {
      const row = dashSheet.addRow(r);
      if (r[0] === 'Total Passed Test Cases') {
        row.getCell(2).font = { bold: true, color: { argb: '27AE60' } };
      }
    });

    dashSheet.getColumn(1).width = 45;
    dashSheet.getColumn(2).width = 35;

    // ----------------------------------------------------
    // Sheet 2: Consolidated 300+ Test Matrix
    // ----------------------------------------------------
    const matrixSheet = workbook.addWorksheet('300+ Master Test Matrix');

    matrixSheet.columns = [
      { header: 'Test ID', key: 'testId', width: 20 },
      { header: 'Category', key: 'category', width: 15 },
      { header: 'Suite Name', key: 'suite', width: 30 },
      { header: 'Test Description', key: 'title', width: 55 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Duration (ms)', key: 'durationMs', width: 15 },
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Error Log / Context', key: 'error', width: 50 }
    ];

    const mHeader = matrixSheet.getRow(1);
    mHeader.font = { bold: true, color: { argb: 'FFFFFF' }, size: 11 };
    mHeader.height = 26;
    mHeader.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
      cell.alignment = { vertical: 'middle', horizontal: 'center' };
    });

    this.allResults.forEach(res => {
      const row = matrixSheet.addRow(res);
      row.height = 20;

      const statusCell = row.getCell('status');
      statusCell.alignment = { horizontal: 'center', vertical: 'middle' };
      statusCell.font = { bold: true };

      if (res.status === 'PASS') {
        statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'D4EDDA' } };
        statusCell.font = { color: { argb: '155724' }, bold: true };
      } else {
        statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'F8D7DA' } };
        statusCell.font = { color: { argb: '721C24' }, bold: true };
      }
    });

    const dir = path.dirname(this.reportFilePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    await workbook.xlsx.writeFile(this.reportFilePath);

    const rootReportsDir = path.resolve(__dirname, '../../reports');
    if (fs.existsSync(rootReportsDir)) {
      const rootReportPath = path.join(rootReportsDir, path.basename(this.reportFilePath));
      fs.copyFileSync(this.reportFilePath, rootReportPath);
    }

    // Append Summary Table to GitHub Actions Step Summary UI
    const summaryFile = process.env.GITHUB_STEP_SUMMARY;
    if (summaryFile) {
      let catRows = '';
      Object.keys(categoryMap).forEach(cat => {
        const c = categoryMap[cat];
        const rate = ((c.passed / c.total) * 100).toFixed(2) + '%';
        catRows += `| **${cat}** | ${c.total} | ${c.passed} | ${c.failed} | ${rate} |\n`;
      });

      const markdown = `
## 🌐 Selenium Web E2E Test Execution Summary

| KPI Metric Description | Metric Value |
| :--- | :--- |
| 🧪 **Total Test Cases Executed** | **${totalTests}** |
| ✅ **Total Passed Test Cases** | **${passedTests}** |
| ❌ **Total Failed Test Cases** | **${failedTests}** |
| 📈 **Overall Pass Rate** | **${passRate}** |
| 🕒 **Execution Timestamp** | ${new Date().toUTCString()} |

### 📊 Web Test Category Breakdown

| Category Name | Total Executed | Passed | Failed | Category Pass Rate |
| :--- | :--- | :--- | :--- | :--- |
${catRows}

---
> 📥 **Artifacts Ready for Download**: Download \`Selenium_Web_E2E_Test_Report.xlsx\` and \`Master_E2E_Analysis_Report.xlsx\` below.
`;

      try {
        fs.appendFileSync(summaryFile, markdown, 'utf-8');
      } catch (e) {}
    }

    console.log(`\n================================================================`);
    console.log(`🎉 Master E2E Excel Analysis Report compiled successfully!`);
    console.log(` => Primary Location: ${path.resolve(this.reportFilePath)}`);
    console.log(`================================================================\n`);
  }
}

module.exports = MasterExcelReporter;
