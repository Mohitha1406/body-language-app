require('dotenv').config();

module.exports = {
  appiumHost: process.env.APPIUM_HOST || '127.0.0.1',
  appiumPort: parseInt(process.env.APPIUM_PORT || '4723', 10),
  appiumPath: process.env.APPIUM_PATH || '/',
  reportPath: './reports/Appium_Mobile_E2E_Test_Report.xlsx',

  // Android Capabilities for Flutter Appium Automation
  androidCapabilities: {
    platformName: 'Android',
    'appium:automationName': 'UiAutomator2',
    'appium:deviceName': process.env.ANDROID_DEVICE_NAME || 'Android_Emulator',
    'appium:app': process.env.ANDROID_APK_PATH || './build/app/outputs/flutter-apk/app-release.apk',
    'appium:appPackage': 'com.example.body_language_app',
    'appium:appActivity': 'com.example.body_language_app.MainActivity',
    'appium:autoGrantPermissions': true,
    'appium:newCommandTimeout': 180
  },

  // iOS Capabilities for iOS Simulator / Device Automation
  iosCapabilities: {
    platformName: 'iOS',
    'appium:automationName': 'XCUITest',
    'appium:deviceName': process.env.IOS_DEVICE_NAME || 'iPhone 15',
    'appium:platformVersion': '17.0',
    'appium:app': process.env.IOS_APP_PATH || './build/ios/iphonesimulator/Runner.app',
    'appium:autoAcceptAlerts': true,
    'appium:newCommandTimeout': 180
  },

  testUser: {
    email: 'mobileqa@confidai.com',
    password: 'Password123!',
    name: 'Mobile QA User'
  }
};
