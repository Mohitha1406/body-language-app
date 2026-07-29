const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class AppiumExcelReporter {
  constructor(reportFilePath) {
    this.reportFilePath = reportFilePath;
    this.testResults = [];
  }

  addResult({ suite, testId, title, status, durationMs, error = '', notes = '' }) {
    this.testResults.push({
      suite,
      testId,
      title,
      status,
      durationMs,
      timestamp: new Date().toISOString(),
      error,
      notes
    });
  }

  async generateReport() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'ConfidAI QA Appium Mobile Automation';
    workbook.created = new Date();

    const totalTests = this.testResults.length;
    const passedTests = this.testResults.filter(r => r.status === 'PASS').length;
    const failedTests = this.testResults.filter(r => r.status === 'FAIL').length;
    const passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(2) + '%' : '0%';

    // Sheet 1: Summary
    const summarySheet = workbook.addWorksheet('Mobile Test Summary');

    summarySheet.mergeCells('A1:E2');
    const titleCell = summarySheet.getCell('A1');
    titleCell.value = 'ConfidAI Mobile Appium E2E Test Analysis Report';
    titleCell.font = { name: 'Arial', size: 16, bold: true, color: { argb: 'FFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };

    summarySheet.addRow([]);
    summarySheet.addRow(['Metric', 'Value']);
    const metricHeader = summarySheet.getRow(4);
    metricHeader.font = { bold: true, color: { argb: 'FFFFFF' } };
    metricHeader.eachCell(c => c.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2C3E50' } });

    [
      ['Platform', 'Android / iOS Appium Automation'],
      ['Execution Timestamp', new Date().toLocaleString()],
      ['Total Mobile Test Cases', totalTests],
      ['Passed', passedTests],
      ['Failed', failedTests],
      ['Pass Rate', passRate]
    ].forEach(row => summarySheet.addRow(row));

    summarySheet.getColumn(1).width = 28;
    summarySheet.getColumn(2).width = 35;

    // Sheet 2: Mobile Details
    const detailSheet = workbook.addWorksheet('Mobile Test Cases');
    detailSheet.columns = [
      { header: 'Test Suite', key: 'suite', width: 25 },
      { header: 'Test ID', key: 'testId', width: 15 },
      { header: 'Mobile Test Description', key: 'title', width: 45 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Duration (ms)', key: 'durationMs', width: 15 },
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Error Trace', key: 'error', width: 50 },
      { header: 'Notes', key: 'notes', width: 35 }
    ];

    const headerRow = detailSheet.getRow(1);
    headerRow.font = { bold: true, color: { argb: 'FFFFFF' } };
    headerRow.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '1A73E8' } };
      cell.alignment = { horizontal: 'center' };
    });

    this.testResults.forEach(res => {
      const row = detailSheet.addRow(res);
      const statusCell = row.getCell('status');
      statusCell.alignment = { horizontal: 'center' };
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
    console.log(`\n[AppiumExcelReporter] Mobile E2E Excel Report generated at:\n => ${path.resolve(this.reportFilePath)}\n`);
  }
}

module.exports = AppiumExcelReporter;
