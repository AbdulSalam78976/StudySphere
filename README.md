# StudySphere - Collaborative Learning Platform 📚

StudySphere is a real-time collaborative platform that connects students to form virtual study groups, share resources, conduct live sessions, and track academic progress together.

## Features

### MVP Features (Implemented)
- ✅ **User Authentication** - Email/password signup and login
- ✅ **Study Groups** - Create, join, and manage study groups
- ✅ **Real-time Chat** - Text-based messaging within groups
- ✅ **Resource Sharing** - Upload, organize, and download study materials
- ✅ **Task Management** - Create and assign tasks for group projects
- ✅ **User Profiles** - Manage your academic profile and information

### Architecture
- **Frontend**: Flutter (Dart) with GetX state management
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **State Management**: GetX
- **UI**: Material Design 3 with custom theming

## Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Supabase account (free tier works)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd group_study_platform
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Project Settings > API
3. Copy your Project URL and anon/public key
4. Update `lib/core/constants/app_constants.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

### 4. Set Up Database Schema

Run these SQL commands in your Supabase SQL Editor:

```sql
-- Users table (extends auth.users)
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  major TEXT,
  university TEXT,
  year INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Groups table
CREATE TABLE groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  course_code TEXT,
  course_name TEXT,
  avatar_url TEXT,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  member_count INTEGER DEFAULT 0,
  is_private BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Group members table
CREATE TABLE group_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- Resources table
CREATE TABLE resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES auth.users(id) NOT NULL,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  category TEXT,
  description TEXT,
  download_count INTEGER DEFAULT 0,
  rating NUMERIC(3,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tasks table
CREATE TABLE tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) NOT NULL,
  assigned_to UUID REFERENCES auth.users(id),
  status TEXT DEFAULT 'todo',
  due_date TIMESTAMPTZ,
  priority INTEGER DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) NOT NULL,
  sender_name TEXT,
  sender_avatar TEXT,
  content TEXT NOT NULL,
  file_url TEXT,
  file_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Storage buckets
-- Create 'resources' bucket in Supabase Storage
-- Create 'avatars' bucket in Supabase Storage
```

### 5. Set Up Storage Buckets

1. Go to Storage in your Supabase dashboard
2. Create two buckets:
   - `resources` (public)
   - `avatars` (public)

### 6. Enable Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Groups policies
CREATE POLICY "Anyone can view public groups" ON groups
  FOR SELECT USING (is_private = false OR created_by = auth.uid());

CREATE POLICY "Users can create groups" ON groups
  FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Group creators can update groups" ON groups
  FOR UPDATE USING (created_by = auth.uid());

-- Group members policies
CREATE POLICY "Members can view group members" ON group_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join groups" ON group_members
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Resources policies (similar pattern)
-- Tasks policies (similar pattern)
-- Messages policies (similar pattern)
```

### 7. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── app/
│   ├── routes/          # Navigation routes
│   └── themes/          # App theming
├── core/
│   └── constants/      # App constants
├── data/
│   ├── models/         # Data models
│   ├── services/       # Supabase services
│   └── repositories/   # Data repositories
├── modules/
│   ├── auth/           # Authentication
│   ├── dashboard/      # Main dashboard
│   ├── groups/         # Study groups
│   ├── chat/           # Messaging
│   ├── resources/      # File sharing
│   ├── tasks/          # Task management
│   └── profile/        # User profile
└── shared/
    └── services/       # Shared services
```

## Key Dependencies

- `get` - State management and routing
- `supabase_flutter` - Backend services
- `cached_network_image` - Image caching
- `file_picker` - File selection
- `timeago` - Relative time formatting

## Development Notes

### Adding New Features
1. Create models in `lib/data/models/`
2. Create services in `lib/data/services/`
3. Create controllers in `lib/modules/[feature]/controllers/`
4. Create views in `lib/modules/[feature]/views/`
5. Add routes in `lib/app/routes/app_pages.dart`

### Database Functions Needed

You'll need to create these PostgreSQL functions in Supabase:

```sql
-- Increment group member count
CREATE OR REPLACE FUNCTION increment_group_member_count(group_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE groups SET member_count = member_count + 1 WHERE id = group_id;
END;
$$ LANGUAGE plpgsql;

-- Decrement group member count
CREATE OR REPLACE FUNCTION decrement_group_member_count(group_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE groups SET member_count = GREATEST(0, member_count - 1) WHERE id = group_id;
END;
$$ LANGUAGE plpgsql;

-- Increment resource download count
CREATE OR REPLACE FUNCTION increment_resource_download_count(resource_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE resources SET download_count = download_count + 1 WHERE id = resource_id;
END;
$$ LANGUAGE plpgsql;
```

## Future Enhancements

- [ ] Video conferencing integration (Jitsi Meet)
- [ ] Shared whiteboard
- [ ] Screen sharing
- [ ] Calendar integration
- [ ] Study timer and analytics
- [ ] AI-powered features
- [ ] Mobile push notifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is for educational purposes.

## Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ using Flutter and Supabase**
