import 'package:flutter/material.dart';

class QuizMessage extends StatefulWidget {
  final List<dynamic> questions;
  final String label;
  final Function(String)
  onReply; // La fonction pour renvoyer la réponse au parent

  const QuizMessage({
    super.key,
    required this.questions,
    required this.label,
    required this.onReply,
  });

  @override
  State<QuizMessage> createState() => _QuizMessageState();
}

class _QuizMessageState extends State<QuizMessage> {
  // C'est ICI que la mémoire est stockée
  late List<TextEditingController> _controllers;
  bool _isSent = false; // Pour verrouiller après envoi

  @override
  void initState() {
    super.initState();
    // On initialise les contrôleurs UNE SEULE FOIS à la création
    _controllers = List.generate(
      widget.questions.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    // On nettoie la mémoire quand le message disparaît
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_isSent) return;

    StringBuffer buffer = StringBuffer();
    buffer.writeln("Voici mes réponses pour le quiz :");

    bool hasContent = false;
    for (int i = 0; i < widget.questions.length; i++) {
      String answer = _controllers[i].text.trim();
      buffer.writeln("${i + 1}. ${widget.questions[i]} : $answer");
      if (answer.isNotEmpty) hasContent = true;
    }

    if (hasContent) {
      setState(() => _isSent = true); // On verrouille le bouton (optionnel)
      widget.onReply(buffer.toString()); // On envoie au parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        ...widget.questions.asMap().entries.map((entry) {
          int idx = entry.key;
          String questionText = entry.value.toString();

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TextField(
              controller: _controllers[idx],
              enabled: !_isSent, // On désactive si déjà envoyé
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: questionText,
                isDense: true,
                filled: true,
                fillColor: _isSent ? Colors.grey[200] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }),

        if (!_isSent)
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send),
            label: Text(widget.label),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.orange, // Mettez votre AppColors.vibrantOrange
              foregroundColor: Colors.white,
            ),
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "✅ Réponses envoyées",
                style: TextStyle(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
