import 'dart:io';
import '../../shared/services/supabase_service.dart';
import '../models/resource_model.dart';
import '../../core/constants/app_constants.dart';

class ResourceService {
  final _supabase = SupabaseService.client;

  // Upload resource
  Future<ResourceModel> uploadResource({
    required String groupId,
    required File file,
    String? category,
    String? description,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Validate file size
    final fileSize = await file.length();
    if (fileSize > AppConstants.maxFileSize) {
      throw Exception('File size exceeds ${AppConstants.maxFileSize ~/ (1024 * 1024)}MB limit');
    }

    // Get file extension
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last.toLowerCase();

    if (!AppConstants.allowedFileTypes.contains(fileExtension)) {
      throw Exception('File type not allowed');
    }

    // Upload to storage
    final storagePath = '$groupId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage
        .from(AppConstants.storageBucketResources)
        .upload(storagePath, file);

    final fileUrl = _supabase.storage
        .from(AppConstants.storageBucketResources)
        .getPublicUrl(storagePath);

    // Create resource record
    final resourceData = {
      'group_id': groupId,
      'uploaded_by': user.id,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileExtension,
      'file_size': fileSize,
      'category': category,
      'description': description,
      'download_count': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final response = await _supabase
        .from(AppConstants.tableResources)
        .insert(resourceData)
        .select()
        .single();

    return ResourceModel.fromJson(response);
  }

  // Get resources for a group
  Future<List<ResourceModel>> getGroupResources(
    String groupId, {
    String? category,
    int limit = AppConstants.itemsPerPage,
    int offset = 0,
  }) async {
    var query = _supabase
        .from(AppConstants.tableResources)
        .select()
        .eq('group_id', groupId);

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((r) => ResourceModel.fromJson(r))
        .toList();
  }

  // Get resource by ID
  Future<ResourceModel?> getResourceById(String resourceId) async {
    final response = await _supabase
        .from(AppConstants.tableResources)
        .select()
        .eq('id', resourceId)
        .maybeSingle();

    if (response == null) return null;
    return ResourceModel.fromJson(response);
  }

  // Delete resource
  Future<void> deleteResource(String resourceId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get resource to check ownership
    final resource = await getResourceById(resourceId);
    if (resource == null) throw Exception('Resource not found');

    if (resource.uploadedBy != user.id) {
      throw Exception('Only the uploader can delete this resource');
    }

    // Extract file path from URL
    final filePath = resource.fileUrl.split('/').last;
    final storagePath = '${resource.groupId}/$filePath';

    // Delete from storage
    await _supabase.storage
        .from(AppConstants.storageBucketResources)
        .remove([storagePath]);

    // Delete from database
    await _supabase
        .from(AppConstants.tableResources)
        .delete()
        .eq('id', resourceId);
  }

  // Increment download count
  Future<void> incrementDownloadCount(String resourceId) async {
    await _supabase.rpc('increment_resource_download_count', params: {
      'resource_id': resourceId,
    });
  }

  // Get resource categories for a group
  Future<List<String>> getResourceCategories(String groupId) async {
    final response = await _supabase
        .from(AppConstants.tableResources)
        .select('category')
        .eq('group_id', groupId)
        .not('category', 'is', null);

    final categories = (response as List)
        .map((r) => r['category'] as String)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    return categories..sort();
  }

  // Search resources
  Future<List<ResourceModel>> searchResources(
    String groupId,
    String query,
  ) async {
    final response = await _supabase
        .from(AppConstants.tableResources)
        .select()
        .eq('group_id', groupId)
        .or('file_name.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(AppConstants.itemsPerPage);

    return (response as List)
        .map((r) => ResourceModel.fromJson(r))
        .toList();
  }
}

