import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flip_card/flip_card.dart';
import '../models/flashcard.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Flashcard> flashcards = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    final response = await http.get(Uri.parse('http://192.168.100.238/flash/show.php'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Flashcard> flashcardsList = body.map((dynamic item) => Flashcard.fromJson(item)).toList();
      setState(() {
        flashcards = flashcardsList;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load flashcards')),
      );
    }
  }

  void checkAnswer(String selectedOption) {
    if (flashcards[currentQuestionIndex].correct == selectedOption) {
      setState(() {
        score++;
      });
    }

    // Move to the next question after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (currentQuestionIndex < flashcards.length - 1) {
        setState(() {
          currentQuestionIndex++;
        });
        cardKey.currentState?.toggleCard();
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Complete'),
        content: Text('Your score is $score/${flashcards.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Pop twice to go back to the previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 350.0, // Adjust the height as per your requirement
              child: GestureDetector(
                onTap: () {
                  cardKey.currentState?.toggleCard();
                },
                child: FlipCard(
                  key: cardKey,
                  flipOnTouch: false,
                  front: _buildCardSide(
                    text: flashcards[currentQuestionIndex].question,
                    bgColor: Colors.blue.shade50,
                    message: 'Click flashcard to see the options', // Added message
                  ),
                  back: _buildOptionsSide(),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide({required String text, required Color bgColor, required String message}) {
    return Container(
      height: 300,
      width: 300,
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            Text(
              message,
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20.0),
        _buildOptionButton(flashcards[currentQuestionIndex].op1),
        SizedBox(height: 10.0),
        _buildOptionButton(flashcards[currentQuestionIndex].op2),
        SizedBox(height: 10.0),
        _buildOptionButton(flashcards[currentQuestionIndex].op3),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildOptionButton(String optionText) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
          checkAnswer(optionText);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[100], // Light blue background color
          foregroundColor: Colors.black, // Text color
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.blue), // Blue border
          ),
          elevation: 0, // Remove the shadow
        ),
        child: Text(optionText),
      ),
    );
  }
}
