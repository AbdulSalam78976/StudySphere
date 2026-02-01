import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes/app_pages.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      setState(() => _currentUser = user);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('No user data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: _currentUser!.avatarUrl != null
                            ? NetworkImage(_currentUser!.avatarUrl!)
                            : null,
                        child: _currentUser!.avatarUrl == null
                            ? Text(
                                _currentUser!.fullName?[0].toUpperCase() ?? 'U',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser!.fullName ?? 'No name',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        _currentUser!.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 32),
                      if (_currentUser!.major != null)
                        _buildInfoTile(
                          context,
                          Icons.school,
                          'Major',
                          _currentUser!.major!,
                        ),
                      if (_currentUser!.university != null)
                        _buildInfoTile(
                          context,
                          Icons.business,
                          'University',
                          _currentUser!.university!,
                        ),
                      if (_currentUser!.year != null)
                        _buildInfoTile(
                          context,
                          Icons.calendar_today,
                          'Year',
                          'Year ${_currentUser!.year}',
                        ),
                      if (_currentUser!.bio != null)
                        _buildInfoTile(
                          context,
                          Icons.info,
                          'Bio',
                          _currentUser!.bio!,
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

