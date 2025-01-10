import 'package:flutter/material.dart';

class CampaignBanner extends StatelessWidget {
  const CampaignBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.green.shade400, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.campaign,
              color: Colors.green,
              size: 40,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                "Good news! We've reduced our transaction costs to save you more.",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width > 400 ? 16 : 14,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
