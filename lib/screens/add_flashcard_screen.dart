import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/flashcard.dart';

class AddFlashcardScreen extends StatefulWidget {
  final Function(Flashcard) addFlashcard;

  AddFlashcardScreen({required this.addFlashcard});

  @override
  _AddFlashcardScreenState createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController correctAnswerController = TextEditingController();

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Flashcard Added'),
        content: Text('Question has been successfully added.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pop(context); // Close the add flashcard screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFlashcard() async {
    final url = Uri.parse('http://192.168.100.238/flash/add.php'); // Replace with your API endpoint for adding flashcards

    final response = await http.post(
      url,
      body: {
        'question': questionController.text,
        'op1': option1Controller.text,
        'op2': option2Controller.text,
        'op3': option3Controller.text,
        'correct': correctAnswerController.text,
      },
    );

    if (response.statusCode == 200) {
      // Assuming your API returns 'success' upon successful insertion
      if (response.body.toLowerCase().contains('success')) {
        _showConfirmationDialog();
        // Create Flashcard object and add locally if needed
        Flashcard flashcard = Flashcard(
          question: questionController.text,
          op1: option1Controller.text,
          op2: option2Controller.text,
          op3: option3Controller.text,
          correct: correctAnswerController.text,
        );
        widget.addFlashcard(flashcard); // Optional: Add to local list if needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add question. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add question. Server error.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Add Flashcard'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildTextField(
                  controller: questionController,
                  labelText: 'Question',
                ),
                SizedBox(height: 12.0),
                _buildTextField(
                  controller: option1Controller,
                  labelText: 'Option 1',
                ),
                SizedBox(height: 12.0),
                _buildTextField(
                  controller: option2Controller,
                  labelText: 'Option 2',
                ),
                SizedBox(height: 12.0),
                _buildTextField(
                  controller: option3Controller,
                  labelText: 'Option 3',
                ),
                SizedBox(height: 12.0),
                _buildTextField(
                  controller: correctAnswerController,
                  labelText: 'Correct Answer',
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addFlashcard();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  child: Text('Add Flashcard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue.shade900),
        filled: true,
        fillColor: Colors.blue.shade50,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue.withOpacity(0.7), width: 1.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }
}
