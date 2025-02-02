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
                );
              },
            ),
    );
  }
}
