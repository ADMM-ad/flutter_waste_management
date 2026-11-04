import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/waste_category_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;

  ReportProvider({ReportService? reportService})
      : _reportService = reportService ?? ReportService();

  List<WasteCategoryModel> _categories = [];
  List<ReportModel> _reports = [];
  ReportModel? _currentReport;

  bool _isLoadingCategories = false;
  bool _isLoadingReports = false;
  bool _isLoadingDetail = false;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  bool _hasMore = true;
  String _selectedStatusFilter = 'all';
  String? _startDateFilter;
  String? _endDateFilter;
  String? _errorMessage;

  List<WasteCategoryModel> get categories => _categories;
  List<ReportModel> get reports => _reports;
  ReportModel? get currentReport => _currentReport;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingReports => _isLoadingReports;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingMore => _isLoadingMore;
  String get selectedStatusFilter => _selectedStatusFilter;
  String? get startDateFilter => _startDateFilter;
  String? get endDateFilter => _endDateFilter;
  String? get errorMessage => _errorMessage;

  /// Load categories
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    final response = await _reportService.getCategories();
    _isLoadingCategories = false;

    if (response.isSuccess && response.data != null) {
      _categories = response.data!;
    }
    notifyListeners();
  }

  /// Load user reports with refresh
  Future<void> fetchReports({
    String? status,
    String? startDate,
    String? endDate,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _reports = [];
    }

    if (status != null) {
      _selectedStatusFilter = status;
    }
    if (startDate != null) {
      _startDateFilter = startDate;
    }
    if (endDate != null) {
      _endDateFilter = endDate;
    }

    _isLoadingReports = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _reportService.getReports(
      page: _currentPage,
      status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
      startDate: _startDateFilter,
      endDate: _endDateFilter,
    );

    _isLoadingReports = false;

    if (response.isSuccess && response.data != null) {
      if (refresh) {
        _reports = response.data!;
      } else {
        _reports.addAll(response.data!);
      }
      if (response.data!.isEmpty) {
        _hasMore = false;
      }
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  /// Load next page for infinite scrolling
  Future<void> loadMoreReports() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final response = await _reportService.getReports(
      page: _currentPage,
      status: _selectedStatusFilter == 'all' ? null : _selectedStatusFilter,
      startDate: _startDateFilter,
      endDate: _endDateFilter,
    );

    _isLoadingMore = false;

    if (response.isSuccess && response.data != null) {
      if (response.data!.isEmpty) {
        _hasMore = false;
      } else {
        _reports.addAll(response.data!);
      }
    } else {
      _hasMore = false;
    }
    notifyListeners();
  }

  /// Fetch single report detail
  Future<void> fetchReportDetail(int id) async {
    _isLoadingDetail = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _reportService.getReportDetail(id);
    _isLoadingDetail = false;

    if (response.isSuccess) {
      _currentReport = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  /// Add new report to local list immediately
  void addReport(ReportModel report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  /// Delete a report by ID
  Future<bool> deleteReport(int id) async {
    final response = await _reportService.deleteReport(id);
    if (response.isSuccess) {
      _reports.removeWhere((r) => r.id == id);
      if (_currentReport?.id == id) {
        _currentReport = null;
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Update existing report in local list
  void updateReportInList(ReportModel updatedReport) {
    final index = _reports.indexWhere((r) => r.id == updatedReport.id);
    if (index != -1) {
      _reports[index] = updatedReport;
    }
    if (_currentReport?.id == updatedReport.id) {
      _currentReport = updatedReport;
    }
    notifyListeners();
  }
}
