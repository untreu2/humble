import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DonateDialog extends StatefulWidget {
  const DonateDialog({Key? key}) : super(key: key);

  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  bool _copied = false;

  void _copyAddress() {
    Clipboard.setData(
      const ClipboardData(text: 'untreu@walletofsatoshi.com'),
    ).then((_) {
      setState(() {
        _copied = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _copied = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Donate')),
      content: SizedBox(
        width: 300,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Lightning:'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _copied
                        ? Row(
                            key: const ValueKey('copied'),
                            children: const [
                              Icon(Icons.check, color: Colors.green),
                              SizedBox(width: 4),
                              Text('Copied!'),
                            ],
                          )
                        : const Text(
                            'untreu@walletofsatoshi.com',
                            key: ValueKey('address'),
                          ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyAddress,
                ),
              ],
            ),
          ],
        ),
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
