import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void saveFeedbackToFirebase(String feedback, int rating) async {
  try {
    await FirebaseFirestore.instance.collection("feedback").add({
      "feedback": feedback,
      "rating": rating,
      "timestamp": DateTime.now(),
    });
    // Show success message
    print("Feedback submitted successfully!");
  } catch (e) {
    print("Failed to submit feedback: $e");
  }
}

class ReviewDialog extends StatelessWidget {
  final Function(String feedback, int rating) onSubmit;

  const ReviewDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    int selectedRating = 0;

    return AlertDialog(
      title: const Text("Rate Our App"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("How would you rate your experience?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
                onPressed: () {
                  selectedRating = index + 1;
                },
              );
            }),
          ),
          TextField(
            controller: feedbackController,
            decoration: const InputDecoration(
              labelText: "Your Feedback",
              hintText: "What can we improve?",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final feedback = feedbackController.text;
            if (selectedRating > 0 && feedback.isNotEmpty) {
              onSubmit(feedback, selectedRating);
              Navigator.pop(context);
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
