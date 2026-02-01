# StudySphere Setup Guide

## Quick Start

### 1. Supabase Configuration

1. Sign up at [supabase.com](https://supabase.com)
2. Create a new project
3. Copy your credentials from Project Settings > API:
   - Project URL
   - anon/public key
4. Update `lib/core/constants/app_constants.dart` with your credentials

### 2. Database Setup

Run the SQL scripts from README.md in your Supabase SQL Editor to create:
- Tables (users, groups, group_members, resources, tasks, messages)
- RLS policies
- Database functions

### 3. Storage Setup

In Supabase Dashboard > Storage:
1. Create bucket: `resources` (public)
2. Create bucket: `avatars` (public)

### 4. Run the App

```bash
flutter pub get
flutter run
```

## Important Notes

- Make sure to update Supabase credentials before running
- Database schema must be set up before using the app
- Storage buckets must be created for file uploads to work

## Troubleshooting

**Error: Supabase not initialized**
- Check your credentials in `app_constants.dart`
- Ensure Supabase project is active

**Error: Table does not exist**
- Run the SQL scripts in Supabase SQL Editor
- Check table names match in `app_constants.dart`

**Error: Storage bucket not found**
- Create the buckets in Supabase Storage
- Check bucket names match in `app_constants.dart`

