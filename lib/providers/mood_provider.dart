import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../database/database_helper.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<MoodEntry> get entries => [..._entries];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Carregar todas as entradas do banco de dados
  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await DatabaseHelper.instance.getMoodEntries();
    } catch (e) {
      _error = 'Erro ao carregar entradas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar uma nova entrada
  Future<void> addEntry(MoodEntry entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await DatabaseHelper.instance.insertMoodEntry(entry);
      final newEntry = entry.copyWith(id: id);
      _entries.insert(0, newEntry); // Adicionar no início da lista
    } catch (e) {
      _error = 'Erro ao adicionar entrada: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar uma entrada existente
  Future<void> updateEntry(MoodEntry entry) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseHelper.instance.updateMoodEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = entry;
      }
    } catch (e) {
      _error = 'Erro ao atualizar entrada: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Excluir uma entrada
  Future<void> deleteEntry(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteMoodEntry(id);
      _entries.removeWhere((entry) => entry.id == id);
    } catch (e) {
      _error = 'Erro ao excluir entrada: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obter uma entrada pelo ID
  MoodEntry? getEntryById(int id) {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }
} 