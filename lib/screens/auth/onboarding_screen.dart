import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../layout/main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _leoIdController = TextEditingController();
  String? _selectedDistrict;
  String? _selectedClubId;
  bool _isLoading = false;

  // Mock Data
  final List<String> _districts = [
    "District 306 A1",
    "District 306 A2",
    "District 306 B1",
    "District 306 B2",
    "District 306 C1",
    "District 306 C2",
  ];

  final Map<String, List<Map<String, String>>> _clubsByDistrict = {
    "District 306 A1": [
      {"id": "1", "name": "Leo Club of Colombo City"},
      {"id": "2", "name": "Leo Club of Moratuwa"},
      {"id": "3", "name": "Leo Club of Piliyandala"},
    ],
    "District 306 A2": [
      {"id": "4", "name": "Leo Club of Dehiwala"},
      {"id": "5", "name": "Leo Club of Kalubowila"},
    ],
    // Add default empty lists for others to prevent errors
    "District 306 B1": [],
    "District 306 B2": [],
    "District 306 C1": [],
    "District 306 C2": [],
  };

  void _handleComplete() async {
    if (_selectedClubId == null && _leoIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Leo ID or select a Club")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Mock API Call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainLayout()),
        (route) => false,
      );
    }
  }

  void _showDistrictDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Select District",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _districts.length,
            itemBuilder: (context, index) {
              final district = _districts[index];
              return ListTile(
                title: Text(district, style: GoogleFonts.inter()),
                onTap: () {
                  setState(() {
                    _selectedDistrict = district;
                    _selectedClubId = null; // Reset club on district change
                  });
                  Navigator.pop(context);
                },
                trailing: _selectedDistrict == district
                    ? Icon(
                        PhosphorIcons.check(),
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showClubDialog() {
    if (_selectedDistrict == null) return;

    final clubs = _clubsByDistrict[_selectedDistrict] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Select Club",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: clubs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "No clubs found for this district",
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    return ListTile(
                      title: Text(club["name"]!, style: GoogleFonts.inter()),
                      onTap: () {
                        setState(() {
                          _selectedClubId = club["id"];
                        });
                        Navigator.pop(context);
                      },
                      trailing: _selectedClubId == club["id"]
                          ? Icon(
                              PhosphorIcons.check(),
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Welcome to LeoConnect!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's set up your profile",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 48),

                // Leo ID Input
                TextField(
                  controller: _leoIdController,
                  decoration: InputDecoration(
                    labelText: "LEO ID (Optional)",
                    hintText: "LEO123456",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(PhosphorIcons.identificationCard()),
                  ),
                ),

                const SizedBox(height: 24),

                // District Selector
                InkWell(
                  onTap: _showDistrictDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "District",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(PhosphorIcons.mapPin()),
                      suffixIcon: Icon(PhosphorIcons.caretDown()),
                    ),
                    child: Text(
                      _selectedDistrict ?? "Select District",
                      style: GoogleFonts.inter(
                        color: _selectedDistrict != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Club Selector
                if (_selectedDistrict != null)
                  InkWell(
                    onTap: _showClubDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Club",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(PhosphorIcons.usersThree()),
                        suffixIcon: Icon(PhosphorIcons.caretDown()),
                      ),
                      child: Text(
                        _clubsByDistrict[_selectedDistrict]?.firstWhere(
                              (c) => c["id"] == _selectedClubId,
                              orElse: () => {"name": "Select Club"},
                            )["name"] ??
                            "Select Club",
                        style: GoogleFonts.inter(
                          color: _selectedClubId != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 48),

                // Complete Button
                FilledButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Complete Setup",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                Text(
                  "You can update this information later in your profile settings",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
