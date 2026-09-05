enum ListingStatus { active, sold, pending }

class ProduceListing {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String commodity;
  final List<String> photoUrls;
  final String qualityGrade; // Grade A, Grade B, Grade C
  final String aiSuggestion; // e.g. "Grade A"
  final double qualityConfidence; // 0.92
  final String aiReason; // "Fresh vibrant colour and uniform size"
  final double mandiBenchmarkPrice; // ₹24/kg
  final double suggestedPrice; // ₹26.40/kg
  final double finalPrice; // Farmer asking price
  final double quantity;
  final String unit; // Quintal, Kg, Ton
  final String description;
  final String village;
  final String taluka;
  final String district;
  final ListingStatus status;
  final bool isFarmerVerified;
  final DateTime createdAt;

  ProduceListing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.commodity,
    required this.photoUrls,
    required this.qualityGrade,
    required this.aiSuggestion,
    required this.qualityConfidence,
    required this.aiReason,
    required this.mandiBenchmarkPrice,
    required this.suggestedPrice,
    required this.finalPrice,
    required this.quantity,
    this.unit = "Quintal",
    required this.description,
    required this.village,
    required this.taluka,
    required this.district,
    this.status = ListingStatus.active,
    this.isFarmerVerified = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get locationString => "$village, $taluka ($district)";

  double get priceDifference => finalPrice - mandiBenchmarkPrice;

  ProduceListing copyWith({
    String? commodity,
    List<String>? photoUrls,
    String? qualityGrade,
    double? suggestedPrice,
    double? finalPrice,
    double? quantity,
    String? unit,
    String? description,
    ListingStatus? status,
  }) {
    return ProduceListing(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerPhone: farmerPhone,
      commodity: commodity ?? this.commodity,
      photoUrls: photoUrls ?? this.photoUrls,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      aiSuggestion: aiSuggestion,
      qualityConfidence: qualityConfidence,
      aiReason: aiReason,
      mandiBenchmarkPrice: mandiBenchmarkPrice,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      village: village,
      taluka: taluka,
      district: district,
      status: status ?? this.status,
      isFarmerVerified: isFarmerVerified,
      createdAt: createdAt,
    );
  }
}
