import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class MoodEntryScreen extends StatefulWidget {
  final int? entryId;

  const MoodEntryScreen({Key? key, this.entryId}) : super(key: key);

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _activitiesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  int _moodRating = 3;
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _loadEntryData();
      _isInit = true;
    }
  }

  void _loadEntryData() {
    if (widget.entryId != null) {
      final moodProvider = Provider.of<MoodProvider>(context, listen: false);
      final entry = moodProvider.getEntryById(widget.entryId!);
      
      if (entry != null) {
        _descriptionController.text = entry.description;
        _activitiesController.text = entry.activities ?? '';
        _selectedDate = entry.date;
        _moodRating = entry.moodRating;
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveMoodEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final entry = MoodEntry(
      id: widget.entryId,
      date: _selectedDate,
      moodRating: _moodRating,
      description: _descriptionController.text.trim(),
      activities: _activitiesController.text.trim().isEmpty
          ? null
          : _activitiesController.text.trim(),
    );

    try {
      if (widget.entryId == null) {
        await moodProvider.addEntry(entry);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await moodProvider.updateEntry(entry);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entrada atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Obter a cor com base no humor
  Color _getMoodColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red.shade300; // Muito triste
      case 2:
        return Colors.orange.shade300; // Triste
      case 3:
        return Colors.yellow.shade300; // Neutro
      case 4:
        return Colors.lightGreen.shade300; // Feliz
      case 5:
        return Colors.green.shade300; // Muito feliz
      default:
        return Colors.grey.shade300;
    }
  }

  // Obter o texto com base no humor
  String _getMoodText(int rating) {
    switch (rating) {
      case 1:
        return 'Muito Triste';
      case 2:
        return 'Triste';
      case 3:
        return 'Neutro';
      case 4:
        return 'Feliz';
      case 5:
        return 'Muito Feliz';
      default:
        return 'Neutro';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entryId != null;
    final formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final moodColor = _getMoodColor(_moodRating);
    final moodText = _getMoodText(_moodRating);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Entrada' : 'Nova Entrada'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formattedDate),
                                    const Icon(Icons.calendar_today),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Humor
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Como você está se sentindo?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  RatingBar.builder(
                                    initialRating: _moodRating.toDouble(),
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemSize: 40,
                                    itemBuilder: (context, index) {
                                      List<IconData> icons = [
                                        Icons.sentiment_very_dissatisfied,
                                        Icons.sentiment_dissatisfied,
                                        Icons.sentiment_neutral,
                                        Icons.sentiment_satisfied,
                                        Icons.sentiment_very_satisfied,
                                      ];
                                      return Icon(
                                        icons[index],
                                        color: _getMoodColor(index + 1),
                                      );
                                    },
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        _moodRating = rating.toInt();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: moodColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      moodText,
                                      style: TextStyle(
                                        color: moodColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descrição',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                hintText: 'Como foi o seu dia?',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, descreva como foi o seu dia';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Atividades (opcional)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Atividades (opcional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _activitiesController,
                              decoration: const InputDecoration(
                                hintText:
                                    'Quais atividades você realizou hoje?',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveMoodEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isEditing ? 'Atualizar' : 'Salvar',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 