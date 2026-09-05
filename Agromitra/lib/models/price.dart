class MandiPrice {
  final String id;
  final String commodity;
  final String commodityIcon;
  final String market;
  final String district;
  final double minPrice;
  final double modalPrice;
  final double maxPrice;
  final String unit; // per Kg or per Quintal
  final String date;
  final String source;
  final double trendPercent; // e.g. +2.4%

  MandiPrice({
    required this.id,
    required this.commodity,
    required this.commodityIcon,
    required this.market,
    required this.district,
    required this.minPrice,
    required this.modalPrice,
    required this.maxPrice,
    this.unit = "kg",
    required this.date,
    this.source = "APMC / Agmarknet",
    this.trendPercent = 0.0,
  });
}
