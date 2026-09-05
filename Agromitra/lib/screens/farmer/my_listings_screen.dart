import 'package:flutter/material.dart';
import '../../models/listing.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/produce_image_view.dart';

class MyListingsScreen extends StatefulWidget {
  final AppState appState;

  const MyListingsScreen({super.key, required this.appState});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool _isGridView = false;

  void _showListingDetailModal(ProduceListing listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listing.commodity,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  StatusBadge(status: listing.status),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: AppTheme.primaryLight,
                  child: ProduceImageView(
                    imageUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : '',
                    commodity: listing.commodity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Asking Price", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      Text(
                        "₹${listing.finalPrice.toStringAsFixed(2)}/kg",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Quantity Available", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      Text(
                        "${listing.quantity.toStringAsFixed(0)} ${listing.unit}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              if (listing.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  listing.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
              const SizedBox(height: 20),
              // Action Buttons: Mark Sold, Update Price, Delete Listing
              Row(
                children: [
                  if (listing.status == ListingStatus.active)
                    Expanded(
                      child: SecondaryButton(
                        label: widget.appState.tr('mark_sold'),
                        icon: Icons.check,
                        onPressed: () {
                          widget.appState.markListingAsSold(listing.id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Listing marked as SOLD")),
                          );
                        },
                        height: 48,
                      ),
                    ),
                  if (listing.status == ListingStatus.active)
                    const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      label: "Edit Price",
                      icon: Icons.edit,
                      onPressed: () {
                        _showEditPriceDialog(listing);
                      },
                      height: 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Delete Produce Record Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmDeleteListing(listing);
                  },
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
                  label: const Text(
                    "Delete This Produce Listing",
                    style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteListing(ProduceListing listing) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Delete Listing?"),
            ],
          ),
          content: Text(
            "Are you sure you want to permanently delete your listing for ${listing.commodity} (${listing.quantity.toStringAsFixed(0)} ${listing.unit})? This will immediately remove it from the buyers' marketplace.",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await widget.appState.deleteListing(listing.id);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("${listing.commodity} listing deleted successfully."),
                      backgroundColor: AppTheme.primaryDark,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
              child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditPriceDialog(ProduceListing listing) {
    final controller = TextEditingController(text: listing.finalPrice.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit ${listing.commodity} Price"),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "New Asking Price (₹/kg)",
              prefixText: "₹ ",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newP = double.tryParse(controller.text);
                if (newP != null) {
                  widget.appState.updateListingPrice(listing.id, newP);
                  Navigator.pop(context); // Close edit dialog
                  Navigator.pop(context); // Close bottom sheet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Asking price updated successfully")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text("Save Price", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    final listings = widget.appState.getFarmerListings(user?.id ?? "f-101");

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('my_listings_title')),
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: "Back",
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
            tooltip: "Toggle View",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.appState.refreshListings(),
        color: AppTheme.primaryGreen,
        child: listings.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
                          child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryGreen, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Produce Listings Yet",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Create your first crop listing to reach verified buyers",
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : _isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      return InkWell(
                        onTap: () => _showListingDetailModal(item),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                child: Container(
                                  height: 110,
                                  width: double.infinity,
                                  color: AppTheme.primaryLight,
                                  child: ProduceImageView(
                                    imageUrl: item.photoUrls.isNotEmpty ? item.photoUrls.first : '',
                                    commodity: item.commodity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.commodity,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _confirmDeleteListing(item),
                                          child: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "₹${item.finalPrice.toStringAsFixed(2)}/kg",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.quantity.toStringAsFixed(0)} ${item.unit}",
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      return ListingCard(
                        listing: item,
                        isFarmerView: true,
                        onTap: () => _showListingDetailModal(item),
                      );
                    },
                  ),
      ),
    );
  }
}
