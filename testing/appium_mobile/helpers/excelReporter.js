const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class AppiumExcelReporter {
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
    workbook.creator = 'ConfidAI Appium Mobile QA Framework';
    workbook.created = new Date();

    const totalTests = this.testResults.length;
    const passedTests = this.testResults.filter(r => r.status === 'PASS').length;
    const failedTests = this.testResults.filter(r => r.status === 'FAIL').length;
    const passRate = totalTests > 0 ? ((passedTests / totalTests) * 100).toFixed(2) + '%' : '0%';
    const totalDuration = this.testResults.reduce((acc, r) => acc + r.durationMs, 0);

    const summarySheet = workbook.addWorksheet('Mobile Execution Summary');

    summarySheet.mergeCells('A1:E2');
    const titleCell = summarySheet.getCell('A1');
    titleCell.value = 'ConfidAI Appium Mobile E2E Test Analysis Report';
    titleCell.font = { name: 'Arial', size: 16, bold: true, color: { argb: 'FFFFFF' } };
    titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '27AE60' } };
    titleCell.alignment = { horizontal: 'center', vertical: 'middle' };

    summarySheet.addRow([]);

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
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '2C3E50' } };
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

    const detailSheet = workbook.addWorksheet('Detailed Mobile Cases');

    detailSheet.columns = [
      { header: 'Suite Name', key: 'suite', width: 30 },
      { header: 'Test ID', key: 'testId', width: 20 },
      { header: 'Test Description', key: 'title', width: 50 },
      { header: 'Category', key: 'category', width: 15 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Duration (ms)', key: 'durationMs', width: 15 },
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Error / Exception Log', key: 'error', width: 50 },
      { header: 'Notes / Context', key: 'notes', width: 35 }
    ];

    const headerRow = detailSheet.getRow(1);
    headerRow.font = { bold: true, color: { argb: 'FFFFFF' }, size: 11 };
    headerRow.height = 26;
    headerRow.eachCell(cell => {
      cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '27AE60' } };
      cell.alignment = { vertical: 'middle', horizontal: 'center' };
    });

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

    const dir = path.dirname(this.reportFilePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    await workbook.xlsx.writeFile(this.reportFilePath);
    console.log(`\n[AppiumExcelReporter] Mobile E2E Excel Analysis Report generated at:\n => ${path.resolve(this.reportFilePath)}\n`);
  }
}

module.exports = AppiumExcelReporter;
