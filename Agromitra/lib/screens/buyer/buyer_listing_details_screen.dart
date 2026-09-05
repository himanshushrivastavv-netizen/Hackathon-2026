import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/produce_image_view.dart';

class BuyerListingDetailsScreen extends StatelessWidget {
  final ProduceListing listing;
  final AppState appState;

  const BuyerListingDetailsScreen({
    super.key,
    required this.listing,
    required this.appState,
  });

  Future<void> _makePhoneCall(BuildContext context) async {
    final cleanPhone = listing.farmerPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (!await launchUrl(phoneUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Calling Farmer: ${listing.farmerPhone}"),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connecting to Farmer: ${listing.farmerPhone}"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final cleanPhone = listing.farmerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneWithCountry = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    final message = Uri.encodeComponent(
      "Hello ${listing.farmerName}, I saw your listing for ${listing.commodity} (${listing.quantity.toStringAsFixed(0)} ${listing.unit} at ₹${listing.finalPrice.toStringAsFixed(2)}/kg) on AgroMitra. I am interested in buying!",
    );
    final Uri waUri = Uri.parse("https://wa.me/$phoneWithCountry?text=$message");

    try {
      if (!await launchUrl(waUri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Connecting via WhatsApp to +$phoneWithCountry"),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Opening chat with ${listing.farmerName}..."),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _showContactConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.handshake_outlined, color: AppTheme.primaryGreen, size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Connect with Farmer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.tr('contact_confirmation'),
                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.farmerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          listing.farmerPhone,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // WhatsApp Chat Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openWhatsApp(context);
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  label: const Text("WhatsApp Farmer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Phone Call Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _makePhoneCall(context);
                  },
                  icon: const Icon(Icons.call, size: 18, color: Colors.white),
                  label: Text(appState.tr('call_now'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appState.tr('cancel'), style: const TextStyle(color: AppTheme.textMuted)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double diff = listing.priceDifference;
    final bool isHigher = diff > 0;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(listing.commodity),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Produce Image Header
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: AppTheme.primaryLight,
                      child: ProduceImageView(
                        imageUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : '',
                        commodity: listing.commodity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title & Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing.commodity,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Direct Farm Listing",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location and Quantity
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        listing.locationString,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        "${listing.quantity.toStringAsFixed(0)} ${listing.unit}",
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price Comparison Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_outlined, color: AppTheme.primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              appState.tr('compare_mandi_badge'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppTheme.borderColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Farmer Asking Price", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${listing.finalPrice.toStringAsFixed(2)}/kg",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("Live Mandi Benchmark", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${listing.mandiBenchmarkPrice.toStringAsFixed(0)}/kg",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isHigher ? Icons.trending_up : Icons.trending_down,
                                size: 16,
                                color: isHigher ? AppTheme.accentYellow : AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Variance: ${isHigher ? '+' : ''}₹${diff.toStringAsFixed(2)}/kg from APMC modal rate",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Farmer Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text("👨‍🌾", style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    listing.farmerName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  if (listing.isFarmerVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, size: 16, color: AppTheme.primaryGreen),
                                  ],
                                ],
                              ),
                              Text(
                                "Farmer in ${listing.village}, ${listing.district}",
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Crop Description
                  if (listing.description.isNotEmpty) ...[
                    const Text(
                      "Produce Details",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.description,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Sticky Bottom "Contact Farmer" Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Total Price", style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      Text(
                        "₹${listing.finalPrice.toStringAsFixed(2)}/kg",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: appState.tr('contact_farmer'),
                    icon: Icons.phone_in_talk,
                    onPressed: () => _showContactConfirmation(context),
                    height: 48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
