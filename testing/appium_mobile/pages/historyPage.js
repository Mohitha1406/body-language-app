class MobileHistoryPage {
  constructor(driverManager) {
    this.dm = driverManager;
    this.driver = driverManager.driver;
  }

  get sessionCards() { return '~~Session History Card'; }
  get refreshListBtn() { return '~Refresh History List'; }

  async getSessionCardCount() {
    if (!this.driver) return 0;
    const cards = await this.driver.$$(this.sessionCards);
    return cards.length;
  }
}

module.exports = MobileHistoryPage;
