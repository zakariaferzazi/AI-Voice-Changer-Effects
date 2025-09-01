import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:voice_changer/providers/app_provider.dart';

class MyFilesScreen extends StatelessWidget {
  const MyFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        if (appProvider.savedFiles.isEmpty) {
          return const Center(
            child: Text('No saved files yet.'),
          );
        }
        return ListView.builder(
          itemCount: appProvider.savedFiles.length,
          itemBuilder: (context, index) {
            final file = appProvider.savedFiles[index];
            final stat = file.statSync();
            return ListTile(
              leading: const Icon(Icons.audio_file),
              title: Text(file.path.split('/').last),
              subtitle: Text(
                '${DateFormat.yMMMd().add_jm().format(stat.modified)} - ${(stat.size / 1024).toStringAsFixed(2)} KB',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => appProvider.shareFile(file),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => appProvider.deleteFile(file),
                  ),
                ],
              ),
              onTap: () => appProvider.playRecording(file.path),
            );
          },
        );
      },
    );
  }
}
