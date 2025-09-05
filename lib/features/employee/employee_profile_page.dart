import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';

class EmployeeProfilePage extends ConsumerWidget {
  const EmployeeProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
              FilledButton.tonal(
                onPressed: () => ref.read(authControllerProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (appUser != null) ...[
                    // Profile Avatar Section
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              appUser.displayName.isNotEmpty
                                  ? appUser.displayName[0].toUpperCase()
                                  : appUser.email[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            appUser.displayName.isNotEmpty
                                ? appUser.displayName
                                : 'Employee',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            appUser.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Profile Details
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ProfileDetailTile(
                      icon: Icons.person,
                      title: 'Display Name',
                      value: appUser.displayName.isNotEmpty
                          ? appUser.displayName
                          : 'Not set',
                    ),
                    _ProfileDetailTile(
                      icon: Icons.email,
                      title: 'Email Address',
                      value: appUser.email,
                    ),
                    _ProfileDetailTile(
                      icon: Icons.badge,
                      title: 'Role',
                      value: appUser.role.toUpperCase(),
                    ),
                    _ProfileDetailTile(
                      icon: Icons.verified_user,
                      title: 'Account Status',
                      value: 'Active',
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Text(
                      'Account Actions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            // TODO: Implement edit profile functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Edit profile functionality coming soon',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement change password functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Change password functionality coming soon',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text('Change Password'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileDetailTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
