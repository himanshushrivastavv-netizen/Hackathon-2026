class PriceLogic {
  /// Directly suggests the live APMC Mandi Modal benchmark price (no confusing formulas)
  static double calculateSuggestedPrice(double modalPrice, [String? grade]) {
    return modalPrice > 0 ? double.parse(modalPrice.toStringAsFixed(2)) : 24.00;
  }

  /// Converts various units (Quintal, Ton, Crate, Kg) to kilograms
  static double convertToKg(double quantity, String unit) {
    switch (unit.toLowerCase()) {
      case 'quintal':
        return quantity * 100.0;
      case 'ton':
        return quantity * 1000.0;
      case 'crate':
        return quantity * 20.0; // Standard 20kg vegetable crate
      case 'kg':
      default:
        return quantity;
    }
  }

  /// Calculates total expected gross payout for farmer
  static double calculateTotalRevenue(double pricePerKg, double quantity, String unit) {
    final totalKg = convertToKg(quantity, unit);
    return pricePerKg * totalKg;
  }

  /// Calculates extra profit gained by selling direct to buyers without 8-12% middlemen mandi commission
  static double calculateMiddlemanSavings(double pricePerKg, double quantity, String unit) {
    final revenue = calculateTotalRevenue(pricePerKg, quantity, unit);
    return revenue * 0.10; // 10% average mandi middleman broker commission saved
  }
}
