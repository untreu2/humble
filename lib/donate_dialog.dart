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
      title: const Text(
        'Donate via Lightning',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 300,
        height: 50,
        child: Row(
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
                          SizedBox(width: 6),
                          Text(
                            'Copied!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'untreu@walletofsatoshi.com',
                        key: ValueKey('address'),
                        style: TextStyle(fontSize: 14),
                      ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy address',
              onPressed: _copyAddress,
            ),
          ],
        ),
      ),
    );
  }
}
