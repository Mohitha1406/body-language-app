const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class ExcelReporter {
  constructor(reportFilePath) {
    this.reportFilePath = reportFilePath;
    this.testResults = [];
    this.startTime = new Date();
  }

  addResult({ suite, testId, title, category = 'Functional', status, durationMs, error = '', notes = '' }) {
    this.testResults.push({
      suite,
      testId,
      title,
      category,
      status,
      durationMs,
      timestamp: new Date().toISOString(),
      error,
      notes
    });
  }

  async generateReport() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'ConfidAI QA Automated E2E Framework';
    workbook.created = new Date();

    const totalTests = this.testResults.length;
    const passedTests = this.testResults.filter(r => r.status === 'PASS').length;
    const failedTests = this.testResults.filter(r => r.status === 'FAIL').length;
    const passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(2) + '%' : '0%';
    const totalDuration = this.testResults.reduce((acc, r) => acc + r.durationMs, 0);

    // ----------------------------------------------------
    // Sheet 1: Dashboard Summary
    // ----------------------------------------------------
    const summarySheet = workbook.addWorksheet('Test Execution Summary');

    // Title Header
    summarySheet.mergeCells('A1:E2');
    const titleCell = summarySheet.getCell('A1');
    titleCell.value = 'ConfidAI Web E2E Selenium Test Analysis Report';
    titleCell.font = { name: 'Arial', size: 16, bold: true, color: { argb: 'FFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };

    summarySheet.addRow([]);

    // KPI Summary Table
    const kpiRows = [
      ['Execution Date', new Date().toLocaleString()],
      ['Total Test Cases Executed', totalTests],
      ['Total Passed', passedTests],
      ['Total Failed', failedTests],
      ['Pass Rate Percentage', passRate],
      ['Total Execution Time', `${(totalDuration / 1000).toFixed(2)} seconds`]
    ];

    summarySheet.addRow(['Metric', 'Value']);
    const metricHeader = summarySheet.getRow(4);
    metricHeader.font = { bold: true, color: { argb: 'FFFFFF' } };
    metricHeader.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '34495E' } };
    });

    kpiRows.forEach(r => {
      const row = summarySheet.addRow(r);
      if (r[0] === 'Total Passed') {
        row.getCell(2).font = { bold: true, color: { argb: '27AE60' } };
      } else if (r[0] === 'Total Failed' && r[1] > 0) {
        row.getCell(2).font = { bold: true, color: { argb: 'C0392B' } };
      }
    });

    summarySheet.getColumn(1).width = 30;
    summarySheet.getColumn(2).width = 35;

    // ----------------------------------------------------
    // Sheet 2: Detailed Results Analysis
    // ----------------------------------------------------
    const detailSheet = workbook.addWorksheet('Detailed Test Cases');

    detailSheet.columns = [
      { header: 'Suite Name', key: 'suite', width: 25 },
      { header: 'Test ID', key: 'testId', width: 15 },
      { header: 'Test Description', key: 'title', width: 45 },
      { header: 'Category', key: 'category', width: 15 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Duration (ms)', key: 'durationMs', width: 15 },
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Error / Exception Log', key: 'error', width: 50 },
      { header: 'Notes / Context', key: 'notes', width: 35 }
    ];

    // Header styling
    const headerRow = detailSheet.getRow(1);
    headerRow.font = { bold: true, color: { argb: 'FFFFFF' }, size: 11 };
    headerRow.height = 26;
    headerRow.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
      cell.alignment = { vertical: 'middle', horizontal: 'center' };
    });

    // Add Rows
    this.testResults.forEach(res => {
      const row = detailSheet.addRow(res);
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

    // Ensure output directory exists
    const dir = path.dirname(this.reportFilePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    await workbook.xlsx.writeFile(this.reportFilePath);

    // Sync copy to root reports directory if running inside testing directory
    const rootReportsDir = path.resolve(__dirname, '../../../reports');
    if (fs.existsSync(rootReportsDir)) {
      const rootReportPath = path.join(rootReportsDir, path.basename(this.reportFilePath));
      fs.copyFileSync(this.reportFilePath, rootReportPath);
    }

    console.log(`\n[ExcelReporter] E2E Excel Analysis Report successfully generated at:\n => ${path.resolve(this.reportFilePath)}\n`);
  }
}

module.exports = ExcelReporter;
