import '../models/ai_result_model.dart';

class AiHistoryRepository {
  final List<AiResultModel> _history = [];

  Future<void> saveAnalysis(AiResultModel result) async {
    _history.insert(0, result);
  }

  Future<List<AiResultModel>> getHistory() async {
    return List.unmodifiable(_history);
  }

  Future<void> deleteAnalysis(AiResultModel result) async {
    _history.remove(result);
  }

  Future<void> clearHistory() async {
    _history.clear();
  }
}