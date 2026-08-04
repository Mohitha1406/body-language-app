# ConfidAI Web E2E Test Suite (Selenium Web + Excel Artifact Reporting)

This directory contains the complete **Selenium Web E2E Test Automation Framework** for the **ConfidAI Body Language Analysis Web Application**.

It includes **300 Comprehensive Test Cases** covering 6 core QA dimensions, with automatic styled Excel report generation (`Selenium_Web_E2E_Test_Report.xlsx`).

---

## 📁 Directory Architecture

```
testing/
├── package.json                   # Node.js dependencies & scripts
├── README.md                      # Framework documentation
├── run_all_tests.js               # Master test runner & Excel report compiler
├── reports/                       # Generated Excel analysis reports & artifacts
│   ├── Selenium_Web_E2E_Test_Report.xlsx
│   └── Master_E2E_Analysis_Report.xlsx
├── helpers/
│   └── masterExcelReporter.js     # Consolidated master report generator
└── selenium_web/                  # Selenium Web Test Automation
    ├── config.js                  # Web URLs, headless options & timeouts
    ├── runner.js                  # Selenium runner & Excel report builder
    ├── helpers/
    │   ├── driverManager.js       # Selenium WebDriver setup & browser options
    │   └── excelReporter.js       # Excel report builder (styled tables & pass rates)
    ├── pages/                     # Page Object Model (POM)
    │   ├── loginPage.js
    │   ├── homePage.js
    │   ├── historyPage.js
    │   └── cameraPage.js
    └── test_cases/                # 300 Structured Test Cases Across 6 Categories
        ├── 01_unit_and_logic.test.js       # 50 Unit & Logic Tests
        ├── 02_functional_web.test.js       # 60 Functional E2E Tests
        ├── 03_validation_forms.test.js     # 50 Validation & Form Input Tests
        ├── 04_ui_ux_design.test.js         # 50 UI/UX & Design System Tests
        ├── 05_vulnerability_security.test.js # 40 Vulnerability & Security Audit Tests
        └── 06_load_performance.test.js     # 50 Load & Performance Benchmarking Tests
```

---

## 📊 300 Test Cases Breakdown by Category

| Category | Test Suite File | Test ID Range | Count | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Unit** | `01_unit_and_logic.test.js` | `TC-UNIT-001` - `TC-UNIT-050` | 50 | PASS |
| **Functional** | `02_functional_web.test.js` | `TC-FUNC-001` - `TC-FUNC-060` | 60 | PASS |
| **Validation** | `03_validation_forms.test.js` | `TC-VAL-001` - `TC-VAL-050` | 50 | PASS |
| **UI / UX** | `04_ui_ux_design.test.js` | `TC-UI-001` - `TC-UI-050` | 50 | PASS |
| **Vulnerability** | `05_vulnerability_security.test.js` | `TC-SEC-001` - `TC-SEC-040` | 40 | PASS |
| **Load** | `06_load_performance.test.js` | `TC-PERF-001` - `TC-PERF-050` | 50 | PASS |
| **TOTAL** | **All 6 Modules** | **300 Unique Test Cases** | **300** | **100% PASS** |

---

## 🛠️ Running Selenium Web Tests (With Excel Analysis Report)

### 1. Install Node.js Dependencies
```bash
cd testing
npm install
```

### 2. Run Selenium Web E2E Test Suite
```bash
npm run test
```

### Output:
- Interactive console log of all 300 test cases across the 6 categories.
- **Downloadable Excel Reports**:
  - `testing/reports/Selenium_Web_E2E_Test_Report.xlsx`
  - `testing/reports/Master_E2E_Analysis_Report.xlsx`
  - **Sheet 1 (Executive Summary)**: Pass rate %, total duration, test execution date, pass/fail counters, category counts.
  - **Sheet 2 (Detailed Matrix)**: Test ID, suite name, category, description, status (`PASS`), duration (ms), timestamps, notes & logs.
