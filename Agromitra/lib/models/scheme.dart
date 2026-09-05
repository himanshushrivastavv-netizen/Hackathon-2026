class GovernmentScheme {
  final String id;
  final String title;
  final String subtitle;
  final String ministry;
  final String category; // Subsidy, Insurance, Loan, Women, Organic
  final String badgeText;
  final String overview;
  final List<String> eligibility;
  final List<String> benefits;
  final List<String> requiredDocuments;
  final String applicationProcess;
  final String importantDates;
  final String officialUrl;

  GovernmentScheme({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ministry,
    required this.category,
    required this.badgeText,
    required this.overview,
    required this.eligibility,
    required this.benefits,
    required this.requiredDocuments,
    required this.applicationProcess,
    required this.importantDates,
    required this.officialUrl,
  });
}
