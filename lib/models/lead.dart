class Lead {
  int? id; // For SQLite auto-increment
  String name;
  String contact;
  String notes;
  String status; // New, Contacted, Converted, Lost

  Lead({
    this.id,
    required this.name,
    required this.contact,
    this.notes = "",
    this.status = "New",
  });

  // Convert Lead → Map (For SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'notes': notes,
      'status': status,
    };
  }

  // Convert Map → Lead
  factory Lead.fromMap(Map<String, dynamic> map) {
    return Lead(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      notes: map['notes'],
      status: map['status'],
    );
  }
}
