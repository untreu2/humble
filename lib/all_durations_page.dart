import 'package:flutter/material.dart';
import 'format_utils.dart';

class AllDurationsPage extends StatefulWidget {
  final List<Duration> durations;

  const AllDurationsPage({Key? key, required this.durations}) : super(key: key);

  @override
  _AllDurationsPageState createState() => _AllDurationsPageState();
}

class _AllDurationsPageState extends State<AllDurationsPage> {
  late List<Duration> _durations;

  @override
  void initState() {
    super.initState();
    _durations = List.from(widget.durations);
  }

  void _deleteDuration(int index) {
    setState(() {
      _durations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: _durations.isEmpty
          ? const Center(child: Text('No fasting durations recorded.'))
          : ListView.builder(
              itemCount: _durations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(formatDuration(_durations[index])),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Are you sure you want to delete?'),
                          content: Text(
                              'Are you sure you want to delete this fasting record? (${formatDuration(_durations[index])})'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteDuration(index);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
