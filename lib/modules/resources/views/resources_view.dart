import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/resource_service.dart';
import '../../../data/models/resource_model.dart';
import 'package:file_picker/file_picker.dart';

class ResourcesView extends StatefulWidget {
  final String? groupId;

  const ResourcesView({super.key, this.groupId});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  final ResourceService _resourceService = ResourceService();
  final List<ResourceModel> _resources = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _loadResources();
    }
  }

  Future<void> _loadResources() async {
    if (widget.groupId == null) return;
    setState(() => _isLoading = true);
    try {
      final resources = await _resourceService.getGroupResources(widget.groupId!);
      setState(() {
        _resources.clear();
        _resources.addAll(resources);
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load resources');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadResource() async {
    if (widget.groupId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // Note: In a real app, you'd need to convert the path to a File object
        // This is a simplified version
        Get.snackbar('Info', 'File upload functionality requires file path handling');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupId == null) {
      return const Center(
        child: Text('No group selected'),
      );
    }

    return Scaffold(
      body: _isLoading && _resources.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _resources.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Resources Yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload files to share with your group',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getFileIcon(resource.fileType)),
                        title: Text(resource.fileName),
                        subtitle: Text(
                          '${resource.fileSizeFormatted} • ${resource.downloadCount} downloads',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            _resourceService.incrementDownloadCount(resource.id);
                            Get.snackbar('Info', 'Download started');
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadResource,
        child: const Icon(Icons.upload),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
        return Icons.video_file;
      case 'mp3':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }
}

