# ConfidAI Automated E2E Testing Suite: Selenium Web & Appium Mobile

This directory contains the complete **End-to-End (E2E) Test Automation Framework** for the **ConfidAI Body Language Analysis System**.

It includes:
1. **Selenium Web E2E Suite** (`selenium_web/`): Full browser automation testing with automated Excel report generation (`exceljs`).
2. **Appium Mobile E2E Suite** (`appium_mobile/`): Standalone mobile test suite stored in a separate Node.js folder for testing iOS and Android Flutter applications.

---

## 📁 Directory Architecture

```
testing/
├── package.json                   # Node.js dependencies & scripts
├── README.md                      # Framework documentation
├── reports/                       # Generated Excel analysis reports & screenshots
│   ├── Selenium_Web_E2E_Test_Report.xlsx
│   └── Appium_Mobile_E2E_Test_Report.xlsx
├── selenium_web/                  # Selenium Web Test Automation
│   ├── config.js                  # Web URLs, timeouts & browser options
│   ├── runner.js                  # Master test runner & Excel report generator
│   ├── helpers/
│   │   ├── driverManager.js       # Selenium WebDriver setup & screenshot utilities
│   │   └── excelReporter.js       # Excel report builder (styled tables & pass rates)
│   ├── pages/                     # Page Object Model (POM)
│   │   ├── loginPage.js
│   │   ├── homePage.js
│   │   ├── historyPage.js
│   │   └── cameraPage.js
│   └── test_cases/
│       ├── 01_auth_e2e.test.js
│       ├── 02_navigation_e2e.test.js
│       └── 03_camera_analysis_e2e.test.js
└── appium_mobile/                 # Appium Mobile Test Automation (Separate Folder)
    ├── config.js                  # Android / iOS Appium Capabilities
    ├── runner.js                  # Mobile test runner & Excel report generator
    ├── helpers/
    │   ├── driverManager.js       # WebdriverIO remote Appium session manager
    │   └── excelReporter.js       # Mobile Excel report generator
    ├── pages/                     # Mobile Page Object Model (POM)
    │   ├── loginPage.js
    │   ├── homePage.js
    │   └── historyPage.js
    └── test_cases/
        ├── 01_mobile_auth_e2e.test.js
        └── 02_mobile_navigation_e2e.test.js
```

---

## 🛠️ Prerequisites & Installation

### 1. Install Node.js Dependencies
Navigate to the `testing/` folder and install dependencies:
```bash
cd testing
npm install
```

---

## 🌐 Running Selenium Web Tests (With Excel Analysis Report)

To run the complete Web E2E test suite and generate the Excel Analysis Report:
```bash
npm run test:web
```

### Output:
- Interactive console log of all executed suites and test cases.
- **Excel Report Location**: `testing/reports/Selenium_Web_E2E_Test_Report.xlsx`
  - **Sheet 1 (Summary)**: Pass rate %, total duration, test execution date, pass/fail counters.
  - **Sheet 2 (Detailed Cases)**: Test ID, suite, description, status (PASS green / FAIL red), duration (ms), timestamps, and error traces.

---

## 📱 Running Appium Mobile Tests

The Appium Mobile Test Suite is isolated under `testing/appium_mobile/`.

### 1. Start Appium Server (v2.x)
Ensure Appium server is installed and running:
```bash
npx appium
```

### 2. Run Appium E2E Tests
```bash
npm run test:mobile
```

### Output:
- **Mobile Excel Report Location**: `testing/reports/Appium_Mobile_E2E_Test_Report.xlsx`

---

## 📊 Summary of Test Reports

Both Selenium Web and Appium Mobile runners automatically output styled Excel `.xlsx` files with KPI summary dashboards and granular test case logs.
