import 'package:flutter/material.dart';
import 'package:lead_manager/models/lead.dart';
import 'package:lead_manager/providers/lead_provider.dart';
import 'package:provider/provider.dart';


class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  String selectedStatus = "New";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lead"),
      ),

      // The FIX: this makes the whole screen scrollable
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Lead Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Contact
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Contact Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Notes",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Status dropdown
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: "Lead Status",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "New", child: Text("New")),
                DropdownMenuItem(value: "Contacted", child: Text("Contacted")),
                DropdownMenuItem(value: "Converted", child: Text("Converted")),
                DropdownMenuItem(value: "Lost", child: Text("Lost")),
              ],
              onChanged: (val) {
                setState(() {
                  selectedStatus = val!;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final contact = _contactController.text.trim();
                  final notes = _notesController.text.trim();

                  if (name.isEmpty || contact.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final lead = Lead(
                    name: name,
                    contact: contact,
                    notes: notes,
                    status: selectedStatus,
                  );

                  Provider.of<LeadProvider>(context, listen: false)
                      .addLead(lead);

                  Navigator.pop(context);
                },
                child: const Text("Save Lead"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
