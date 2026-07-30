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

    const unitCount = this.allResults.filter(r => r.category === 'Unit').length;
    const valCount = this.allResults.filter(r => r.category === 'Validation').length;
    const funcCount = this.allResults.filter(r => r.category === 'Functional').length;
    const uiCount = this.allResults.filter(r => r.category === 'UI/UX').length;

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

    // KPI Metrics Summary Table
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
      ['Total Execution Duration', `${(totalDuration / 1000).toFixed(2)} seconds`],
      ['--- CATEGORY BREAKDOWN ---', '--- COUNTS ---'],
      ['Unit Test Cases (flutter test)', unitCount],
      ['Validation Test Cases (Forms/Rules)', valCount],
      ['Functional Test Cases (End-to-End)', funcCount],
      ['UI/UX Test Cases (Aesthetics/Views)', uiCount],
      ['--- DEPLOYABLE STATUS CHECK ---', '--- STATUS ---'],
      ['Flutter Web Release Build (flutter build web --release)', this.deployableStatus.webReleaseBuild],
      ['Flutter Android Release APK (flutter build apk --release)', this.deployableStatus.apkReleaseBuild]
    ];

    kpiRows.forEach(r => {
      const row = dashSheet.addRow(r);
      if (r[0] === 'Total Passed Test Cases') {
        row.getCell(2).font = { bold: true, color: { argb: '27AE60' } };
      } else if (r[0].includes('Release')) {
        row.getCell(2).font = { bold: true, color: { argb: '1A73E8' } };
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
    console.log(`\n================================================================`);
    console.log(`🎉 Master E2E Excel Analysis Report compiled successfully!`);
    console.log(` => Location: ${path.resolve(this.reportFilePath)}`);
    console.log(`================================================================\n`);
  }
}

module.exports = MasterExcelReporter;
