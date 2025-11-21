import 'package:flutter/material.dart';
import 'package:lead_manager/models/lead.dart';
import 'package:lead_manager/providers/lead_provider.dart';
import 'package:provider/provider.dart';


class LeadDetailsScreen extends StatefulWidget {
  final Lead lead;

  const LeadDetailsScreen({super.key, required this.lead});

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final List<String> statuses = ["New", "Contacted", "Converted", "Lost"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeadProvider>(context, listen: false);
    Lead lead = widget.lead;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lead Details"),
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _EditLeadScreen(lead: lead),
                ),
              );
            },
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await provider.deleteLead(lead.id!);
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lead.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Text("Contact: ${lead.contact}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text("Notes: ${lead.notes}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Text("Update Status:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: statuses.map((status) {
                final isSelected = lead.status == status;

                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade200,
                  onSelected: (_) async {
                    setState(() {
                      lead.status = status;
                    });
                    await provider.updateLead(lead);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// EDIT LEAD SCREEN (INSIDE SAME FILE)

class _EditLeadScreen extends StatefulWidget {
  final Lead lead;
  const _EditLeadScreen({required this.lead});

  @override
  State<_EditLeadScreen> createState() => _EditLeadScreenState();
}

class _EditLeadScreenState extends State<_EditLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController contactController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.lead.name);
    contactController = TextEditingController(text: widget.lead.contact);
    notesController = TextEditingController(text: widget.lead.notes);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeadProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Lead"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Lead Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: "Contact",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      widget.lead.name = nameController.text.trim();
                      widget.lead.contact = contactController.text.trim();
                      widget.lead.notes = notesController.text.trim();

                      await provider.updateLead(widget.lead);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
