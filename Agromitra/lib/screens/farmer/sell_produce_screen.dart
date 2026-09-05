import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/listing.dart';
import '../../models/price.dart';
import '../../services/app_state.dart';
import '../../services/price_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/price_logic.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/produce_image_view.dart';

class SellProduceScreen extends StatefulWidget {
  final AppState appState;
  final VoidCallback? onListingCreated;

  const SellProduceScreen({super.key, required this.appState, this.onListingCreated});

  @override
  State<SellProduceScreen> createState() => _SellProduceScreenState();
}

class _SellProduceScreenState extends State<SellProduceScreen> {
  int _currentStep = 0; // 0: Details, 1: Photos, 2: Pricing & Profit

  // Maximum Image Size Limit: 10 MB
  static const int maxImageSizeBytes = 10 * 1024 * 1024;

  // Form State
  String _selectedCommodity = "Tomato";
  final _quantityController = TextEditingController(text: "20");
  String _selectedUnit = "Quintal";
  final _descriptionController = TextEditingController(
    text: "Fresh harvest directly from farm. Grade-A quality, hand-picked this morning.",
  );

  // Photos State
  final List<String> _uploadedPhotos = [
    "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80",
    "https://images.unsplash.com/photo-1546470427-e26264be0b11?w=500&q=80",
  ];
  final List<Uint8List> _uploadedPhotoBytes = [];
  final ImagePicker _picker = ImagePicker();

  // Pricing State
  double _mandiBenchmark = 24.0;
  final _finalPriceController = TextEditingController(text: "24.00");
  bool _isPublishing = false;

  final List<String> _commodities = [
    "Tomato",
    "Onion",
    "Potato",
    "Cotton",
    "Soybean",
    "Pomegranate",
    "Banana",
    "Wheat",
    "Rice",
    "Mango",
    "Chilli",
    "Garlic",
    "Ginger",
    "Maize",
  ];

  final List<String> _units = ["Quintal", "Kg", "Ton", "Crate"];

  @override
  void initState() {
    super.initState();
    _updatePricingDefaults();
    _quantityController.addListener(() {
      setState(() {});
    });
    _finalPriceController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _finalPriceController.dispose();
    super.dispose();
  }

  void _updatePricingDefaults() {
    final MandiPrice? mp = PriceService.getPriceForCommodity(_selectedCommodity);
    _mandiBenchmark = mp?.modalPrice ?? 24.0;
    _finalPriceController.text = _mandiBenchmark.toStringAsFixed(2);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_uploadedPhotos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 photos allowed")),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        // Enforce 10 MB strict limit
        if (bytes.lengthInBytes > maxImageSizeBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Image size exceeds 10 MB limit. Please choose a smaller photo."),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }

        setState(() {
          _uploadedPhotos.add(image.path);
          _uploadedPhotoBytes.add(bytes);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Photo added (${_uploadedPhotos.length}/3) - ${((bytes.lengthInBytes) / (1024 * 1024)).toStringAsFixed(2)} MB"),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not pick image: $e")),
        );
      }
    }
  }

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);

    try {
      final user = widget.appState.currentUser;
      final double finalPrice = double.tryParse(_finalPriceController.text) ?? _mandiBenchmark;
      final double qty = double.tryParse(_quantityController.text) ?? 10.0;

      // Upload photos to Supabase Storage / persistent URIs
      final List<String> finalPhotoUrls = [];
      for (int i = 0; i < _uploadedPhotos.length; i++) {
        final photoPath = _uploadedPhotos[i];
        if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
          finalPhotoUrls.add(photoPath);
        } else if (i < _uploadedPhotoBytes.length) {
          final uploadedUrl = await SupabaseService.uploadProduceImage(
            _uploadedPhotoBytes[i],
            _selectedCommodity,
          );
          finalPhotoUrls.add(uploadedUrl);
        } else {
          finalPhotoUrls.add(photoPath);
        }
      }

      if (finalPhotoUrls.isEmpty) {
        finalPhotoUrls.add('https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&q=80');
      }

      final newListing = ProduceListing(
        id: "lst-${DateTime.now().millisecondsSinceEpoch}",
        farmerId: user?.id ?? "f-101",
        farmerName: user?.name ?? "Farmer",
        farmerPhone: user?.phone ?? "+91 98765 43210",
        commodity: _selectedCommodity,
        photoUrls: finalPhotoUrls,
        qualityGrade: "Fresh Harvest",
        aiSuggestion: "Direct Mandi Benchmark",
        qualityConfidence: 1.0,
        aiReason: "Live APMC benchmark matched rate",
        mandiBenchmarkPrice: _mandiBenchmark,
        suggestedPrice: _mandiBenchmark,
        finalPrice: finalPrice,
        quantity: qty,
        unit: _selectedUnit,
        description: _descriptionController.text.trim(),
        village: user?.village ?? "Bhiwandi",
        taluka: user?.taluka ?? "Bhiwandi",
        district: user?.district ?? "Thane",
        status: ListingStatus.active,
        isFarmerVerified: user?.isVerifiedSeller ?? true,
      );

      // Save to AppState and publish online to Supabase
      await widget.appState.addListing(newListing);

      if (mounted) {
        setState(() => _isPublishing = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to publish listing: $e"), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("🌾", style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.appState.tr('listing_success_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.appState.tr('listing_success_desc'),
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCommodity,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "₹${_finalPriceController.text}/kg",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: "View in My Listings",
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (widget.onListingCreated != null) {
                    widget.onListingCreated!();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('nav_sell')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar & Step Tabs
            _buildStepIndicator(),
            const Divider(height: 1, color: AppTheme.borderColor),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentStepView(),
              ),
            ),

            // Bottom Navigation Actions
            _buildBottomNavActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'num': 1, 'title': 'Details'},
      {'num': 2, 'title': 'Photos (Max 10MB)'},
      {'num': 3, 'title': 'Price & Profit'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((s) {
          final int stepIndex = (s['num'] as int) - 1;
          final bool isPassed = _currentStep > stepIndex;
          final bool isCurrent = _currentStep == stepIndex;

          return InkWell(
            onTap: () {
              if (stepIndex <= _currentStep) {
                setState(() => _currentStep = stepIndex);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isPassed || isCurrent ? AppTheme.primaryGreen : AppTheme.scaffoldBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrent ? AppTheme.primaryGreen : AppTheme.borderColor,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isPassed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            "${s['num']}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s['title'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? AppTheme.primaryGreen : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Details();
      case 1:
        return _buildStep2Photos();
      case 2:
        return _buildStep3Pricing();
      default:
        return _buildStep1Details();
    }
  }

  // STEP 1: Details
  Widget _buildStep1Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Step 1: Produce Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          "Select commodity and available harvest quantity",
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Commodity Dropdown
        const Text(
          "Commodity / शेतमाल",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCommodity,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryGreen),
              items: _commodities.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Text(ProduceImageView.getCommodityEmoji(c), style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        c,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCommodity = val;
                    _updatePricingDefaults();
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Quantity and Unit
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                label: widget.appState.tr('quantity'),
                hint: "e.g. 25",
                controller: _quantityController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.scale,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Unit",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedUnit,
                        isExpanded: true,
                        items: _units.map((u) {
                          return DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 14)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnit = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Description
        CustomTextField(
          label: widget.appState.tr('crop_desc'),
          hint: "Provide harvest notes, variety, packing type...",
          controller: _descriptionController,
          maxLines: 3,
        ),
      ],
    );
  }

  // STEP 2: Photos (with 10 MB strict limit)
  Widget _buildStep2Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Step 2: Produce Photos",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          "Upload up to 3 real harvest photos (Maximum 10 MB per photo)",
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Photo Gallery Preview Grid
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 120,
                  margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: i < _uploadedPhotos.length
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ProduceImageView(
                              imageUrl: _uploadedPhotos[i],
                              commodity: _selectedCommodity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _uploadedPhotos.removeAt(i);
                                    if (i < _uploadedPhotoBytes.length) {
                                      _uploadedPhotoBytes.removeAt(i);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: () => _pickImage(ImageSource.gallery),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined, color: AppTheme.textMuted, size: 28),
                              const SizedBox(height: 4),
                              Text("Slot ${i + 1}", style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        // Camera + Gallery Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text("Take Photo"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text("Choose from Gallery"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.primaryGreen, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Photos help buyers verify produce freshness directly. Strict 10 MB limit applied per photo.",
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Live Mandi Benchmark & Profit Calculator (No Complex AI Grading)
  Widget _buildStep3Pricing() {
    final double askingPrice = double.tryParse(_finalPriceController.text) ?? _mandiBenchmark;
    final double qty = double.tryParse(_quantityController.text) ?? 10.0;
    final double totalRevenue = PriceLogic.calculateTotalRevenue(askingPrice, qty, _selectedUnit);
    final double middlemanSaved = PriceLogic.calculateMiddlemanSavings(askingPrice, qty, _selectedUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Step 3: Live Mandi Price & Direct Profit",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          "Real-time APMC Mandi benchmark rate suggested for fair, direct sale.",
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 20),

        // Live Benchmark Card
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
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.analytics_outlined, color: AppTheme.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Live $_selectedCommodity Benchmark",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Latest APMC",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Recommended Market Price", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      SizedBox(height: 2),
                      Text("Direct Modal Rate", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                  Text(
                    "₹${_mandiBenchmark.toStringAsFixed(2)}/kg",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Farmer Asking Price Input
        CustomTextField(
          label: widget.appState.tr('final_asking_price'),
          hint: "e.g. 24.00",
          controller: _finalPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixText: "₹ ",
          suffixText: " / kg",
        ),
        const SizedBox(height: 6),
        const Text(
          "Suggested at live mandi rate. You can increase or decrease based on your produce quality.",
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 20),

        // Live Farmer Profit & Earnings Calculator Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined, color: AppTheme.primaryGreen, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "Farmer Total Earnings Projection",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Quantity: $qty $_selectedUnit",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Rate: ₹${askingPrice.toStringAsFixed(2)}/kg",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Estimated Direct Payout:",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    Text(
                      "₹${totalRevenue.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "You earn ~₹${middlemanSaved.toStringAsFixed(0)} extra by connecting directly with buyers without mandi commission!",
                      style: const TextStyle(fontSize: 11, color: AppTheme.primaryDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: SecondaryButton(
                label: "Back",
                onPressed: _isPublishing
                    ? null
                    : () {
                        setState(() => _currentStep--);
                      },
                height: 50,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: PrimaryButton(
              label: _currentStep == 2
                  ? (_isPublishing ? "Publishing..." : widget.appState.tr('publish_listing'))
                  : "Next Step",
              icon: _currentStep == 2 ? Icons.cloud_upload_outlined : Icons.arrow_forward,
              isLoading: _isPublishing,
              onPressed: _isPublishing
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _handlePublish();
                      }
                    },
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
