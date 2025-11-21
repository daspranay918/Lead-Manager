import 'package:flutter/material.dart';
import 'package:lead_manager/providers/lead_provider.dart';
import 'package:lead_manager/providers/theme_provider.dart';
import 'package:lead_manager/screens/add_lead/add_lead_screen.dart';
import 'package:lead_manager/screens/lead_details/lead_details_screen.dart';
import 'package:lead_manager/services/export_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> filters = const [
    "All",
    "New",
    "Contacted",
    "Converted",
    "Lost",
  ];

  final ScrollController _scrollController = ScrollController();

  Color getStatusColor(String status) {
    switch (status) {
      case "New":
        return Colors.blue;
      case "Contacted":
        return Colors.orange;
      case "Converted":
        return Colors.green;
      case "Lost":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<LeadProvider>(context, listen: false);

    // Listen for scroll end to load more
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        provider.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lead Manager"),
        centerTitle: true,
        actions: [
          //  SMALL COMPACT THEME SWITCH
          Transform.scale(
            scale: 0.8, // reduce switch size
            child: Switch(
              value: context.watch<ThemeProvider>().isDark,
              onChanged: (val) {
                context.read<ThemeProvider>().toggleTheme();
              },
            ),
          ),
          const SizedBox(width: 6),

          // 📄 EXPORT BUTTON
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              final leads = context.read<LeadProvider>().leads;

              if (leads.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No leads to export")),
                );
                return;
              }

              final jsonString = ExportService.generateJson(leads);
              final file = await ExportService.saveJsonFile(jsonString);

              await Share.shareXFiles([
                XFile(file.path),
              ], text: "Lead Export File (JSON)");
            },
          ),
        ],
      ),

      body: Column(
        children: [
          //  SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search leads...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                context.read<LeadProvider>().setSearchQuery(value);
              },
            ),
          ),

          // FILTER CHIPS (NO CHECKMARK)
          SizedBox(
            height: 56,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (_, index) {
                final filter = filters[index];
                final selected = leadProvider.filterStatus == filter;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    showCheckmark: false, // removed tick mark ✔
                    selectedColor: Colors.blue.shade300,
                    onSelected: (_) {
                      leadProvider.setFilter(filter);
                    },
                  ),
                );
              },
            ),
          ),

          //  LEAD LIST + PAGINATION + ANIMATIONS
          Expanded(
            child: Consumer<LeadProvider>(
              builder: (context, provider, child) {
                final leads = provider.leads;

                if (leads.isEmpty) {
                  return Center(
                    child: Text(
                      provider.searchQuery.isNotEmpty
                          ? "No results for \"${provider.searchQuery}\""
                          : "No leads found",
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.hasMore ? leads.length + 1 : leads.length,
                  itemBuilder: (context, index) {
                    if (index == leads.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final lead = leads[index];

                    return TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 400),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 25 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),

                          title: Text(
                            lead.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16),
                                  const SizedBox(width: 4),
                                  Text(lead.contact),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // STATUS BADGE
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                    lead.status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  lead.status,
                                  style: TextStyle(
                                    color: getStatusColor(lead.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LeadDetailsScreen(lead: lead),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ➕ ADD LEAD
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLeadScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
