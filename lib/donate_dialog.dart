import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonateDialog extends StatelessWidget {
  const DonateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Donate')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Row(children: [Expanded(child: Text('Lightning:'))]),
          Row(
            children: [
              const Expanded(child: Text('untreu@walletofsatoshi.com')),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(
                      const ClipboardData(text: 'untreu@walletofsatoshi.com'))
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied.')),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Center(child: Text('Close')),
        ),
      ],
    );
  }
}
