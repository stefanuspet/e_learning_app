import 'package:flutter/foundation.dart';
import '../api/discussion_api.dart';

class DiscussionProvider with ChangeNotifier {
  final DiscussionApi _discussionApi;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _subjectDetail;
  List<dynamic> _discussions = [];
  Map<String, dynamic>? _threadDetail;

  DiscussionProvider(this._discussionApi);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get subjectDetail => _subjectDetail;
  List<dynamic> get discussions => _discussions;
  Map<String, dynamic>? get threadDetail => _threadDetail;

  Future<void> loadSubjectAndDiscussions(int subjectId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _subjectDetail = await _discussionApi.getSubjectDetail(subjectId);
      _discussions = await _discussionApi.getDiscussions(subjectId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadThread(int subjectId, int threadId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _threadDetail =
          await _discussionApi.getDiscussionThread(subjectId, threadId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createDiscussion(
      int subjectId, Map<String, dynamic> payload) async {
    try {
      await _discussionApi.createDiscussion(subjectId, payload);
      await loadSubjectAndDiscussions(subjectId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> replyDiscussion(
      int subjectId, int threadId, Map<String, dynamic> payload) async {
    try {
      await _discussionApi.replyDiscussion(subjectId, threadId, payload);
      await loadThread(subjectId, threadId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

