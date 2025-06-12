import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class CopyableTextWidget extends StatelessWidget {
  final String textToCopy;
  final String labelText;

  CopyableTextWidget({required this.textToCopy, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Text Widget displaying the label
        Expanded(
          child: Text(
            '$labelText: $textToCopy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Icon Button to copy the text
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            // Copy text to clipboard
            Clipboard.setData(ClipboardData(text: textToCopy));
            // Show a snackbar or toast
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم نسخ النص: $textToCopy')),
            );
          },
        ),
      ],
    );
  }
}
