import 'package:flutter/material.dart';
import 'package:lead_manager/models/lead.dart';
import 'package:lead_manager/services/db_service.dart';


class LeadProvider extends ChangeNotifier {
  final List<Lead> _leads = [];

  // Filters
  String _filterStatus = "All";     // <-- REQUIRED (this fixes your error)
  String _searchQuery = "";

  // Pagination
  final int _limit = 20;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // GETTERS

  String get filterStatus => _filterStatus;     // <-- This getter must exist
  String get searchQuery => _searchQuery;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  List<Lead> get leads {
    List<Lead> filtered = _leads;

    // Apply status filter

    if (_filterStatus != "All") {
      filtered = filtered.where((lead) => lead.status == _filterStatus).toList();
    }

    // Apply search

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((lead) => lead.name.toLowerCase().contains(q))
          .toList();
    }

    return filtered;
  }

  // Pagination: Load First Page

  Future<void> loadLeads() async {
    _offset = 0;
    _hasMore = true;
    _leads.clear();

    List<Lead> newLeads =
        await DBService.instance.getLeadsPaginated(_offset, _limit);

    _leads.addAll(newLeads);

    if (newLeads.length < _limit) _hasMore = false;

    notifyListeners();
  }

  // Pagination: Load More
  
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _offset += _limit;

    List<Lead> newLeads =
        await DBService.instance.getLeadsPaginated(_offset, _limit);

    _leads.addAll(newLeads);

    if (newLeads.length < _limit) _hasMore = false;

    _isLoadingMore = false;
    notifyListeners();
  }

  // CRUD OPERATIONS

  Future<void> addLead(Lead lead) async {
    await DBService.instance.insertLead(lead);
    await loadLeads();
  }

  Future<void> updateLead(Lead lead) async {
    await DBService.instance.updateLead(lead);
    await loadLeads();
  }

  Future<void> deleteLead(int id) async {
    await DBService.instance.deleteLead(id);
    await loadLeads();
  }

  // FILTER HANDLERS

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }
}
