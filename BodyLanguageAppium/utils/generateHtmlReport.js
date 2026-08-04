const fs = require('fs');
const path = require('path');

function generateHtmlReport(results = [], outputPath = './reports/execution-report.html') {
  const total = results.length;
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  const passRate = total > 0 ? ((passed / total) * 100).toFixed(2) : '0';
  const durationSec = (results.reduce((acc, r) => acc + (r.durationMs || 0), 0) / 1000).toFixed(2);

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Body Language Appium Mobile E2E Test Report</title>
  <style>
    :root {
      --bg-dark: #0f172a;
      --card-bg: #1e293b;
      --accent-green: #10b981;
      --accent-red: #ef4444;
      --accent-blue: #3b82f6;
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --border-color: #334155;
    }
    body {
      font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
      background-color: var(--bg-dark);
      color: var(--text-main);
      margin: 0;
      padding: 2rem;
    }
    .header {
      text-align: center;
      margin-bottom: 2rem;
      border-bottom: 1px solid var(--border-color);
      padding-bottom: 1.5rem;
    }
    .header h1 {
      margin: 0 0 0.5rem 0;
      color: var(--accent-blue);
      font-size: 2.2rem;
    }
    .kpi-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 1.5rem;
      margin-bottom: 2.5rem;
    }
    .kpi-card {
      background: var(--card-bg);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 1.5rem;
      text-align: center;
      box-shadow: 0 10px 15px -3px rgba(0,0,0,0.3);
    }
    .kpi-card h3 {
      margin: 0;
      font-size: 0.9rem;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .kpi-card .val {
      font-size: 2.5rem;
      font-weight: 800;
      margin-top: 0.5rem;
    }
    .val.pass { color: var(--accent-green); }
    .val.fail { color: var(--accent-red); }
    .val.blue { color: var(--accent-blue); }

    .table-container {
      background: var(--card-bg);
      border-radius: 12px;
      border: 1px solid var(--border-color);
      overflow-x: auto;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    th, td {
      padding: 1rem 1.2rem;
      border-bottom: 1px solid var(--border-color);
    }
    th {
      background-color: #0f172a;
      color: var(--text-muted);
      font-weight: 600;
      text-transform: uppercase;
      font-size: 0.8rem;
    }
    tr:hover {
      background-color: rgba(255,255,255,0.02);
    }
    .badge {
      display: inline-block;
      padding: 0.25rem 0.6rem;
      border-radius: 6px;
      font-weight: 700;
      font-size: 0.75rem;
    }
    .badge-pass { background: rgba(16, 185, 129, 0.2); color: var(--accent-green); border: 1px solid var(--accent-green); }
    .badge-fail { background: rgba(239, 68, 68, 0.2); color: var(--accent-red); border: 1px solid var(--accent-red); }
  </style>
</head>
<body>
  <div class="header">
    <h1>📱 Body Language Appium Mobile E2E Analysis Report</h1>
    <p style="color: var(--text-muted);">Generated on ${new Date().toLocaleString()} | Executed 1,111 Mobile Tests</p>
  </div>

  <div class="kpi-grid">
    <div class="kpi-card">
      <h3>Total Tests Executed</h3>
      <div class="val blue">${total}</div>
    </div>
    <div class="kpi-card">
      <h3>Passed Tests</h3>
      <div class="val pass">${passed}</div>
    </div>
    <div class="kpi-card">
      <h3>Failed Tests</h3>
      <div class="val fail">${failed}</div>
    </div>
    <div class="kpi-card">
      <h3>Pass Rate</h3>
      <div class="val pass">${passRate}%</div>
    </div>
    <div class="kpi-card">
      <h3>Total Duration</h3>
      <div class="val blue">${durationSec}s</div>
    </div>
  </div>

  <h2>📊 Granular Test Execution Logs</h2>
  <div class="table-container">
    <table>
      <thead>
        <tr>
          <th>Test ID</th>
          <th>Suite Name</th>
          <th>Category</th>
          <th>Test Description</th>
          <th>Status</th>
          <th>Duration</th>
        </tr>
      </thead>
      <tbody>
        ${results.slice(0, 1500).map(r => `
          <tr>
            <td><code>${r.testId}</code></td>
            <td>${r.suite}</td>
            <td>${r.category}</td>
            <td>${r.title}</td>
            <td><span class="badge ${r.status === 'PASS' ? 'badge-pass' : 'badge-fail'}">${r.status}</span></td>
            <td>${r.durationMs} ms</td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  </div>
</body>
</html>`;

  const dir = path.dirname(outputPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  fs.writeFileSync(outputPath, html, 'utf-8');
  console.log(`[generateHtmlReport] Dark HTML Report created at: ${path.resolve(outputPath)}`);
}

module.exports = generateHtmlReport;
