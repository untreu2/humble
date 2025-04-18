import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _launchGitHub() async {
    const url = 'https://github.com/untreu2/humble';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Donate via Lightning (BTC)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            height: 25,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            children: [
                              Icon(Icons.check,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Copied!',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'untreu@walletofsatoshi.com',
                            key: const ValueKey('address'),
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy LN address',
                  onPressed: _copyAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Source Code',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _launchGitHub,
            child: Text(
              'github.com/untreu2/humble',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
