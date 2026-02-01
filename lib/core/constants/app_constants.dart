class AppConstants {
  // App Info
  static const String appName = 'StudySphere';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration
  // TODO: Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Storage Buckets
  static const String storageBucketResources = 'resources';
  static const String storageBucketAvatars = 'avatars';
  
  // Database Tables
  static const String tableUsers = 'users';
  static const String tableGroups = 'groups';
  static const String tableGroupMembers = 'group_members';
  static const String tableResources = 'resources';
  static const String tableTasks = 'tasks';
  static const String tableMessages = 'messages';
  
  // File Upload Limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'mp4',
    'mp3',
  ];
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Group Settings
  static const int maxGroupMembers = 50;
  static const int minGroupNameLength = 3;
  static const int maxGroupNameLength = 50;
  
  // Chat Settings
  static const int maxMessageLength = 1000;
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy • hh:mm a';
}

