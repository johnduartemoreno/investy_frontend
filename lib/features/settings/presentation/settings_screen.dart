import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/presentation/widgets/custom_card.dart';
import '../../../../core/presentation/widgets/responsive_center.dart';
import '../../../../l10n/app_localizations.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'providers/avatar_upload_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Column(
            children: [
              _buildProfileSection(context, ref, l10n),
              const SizedBox(height: AppDimens.spacingXL),
              _buildSettingsSection(context, l10n),
              const SizedBox(height: AppDimens.spacingXL),
              _buildAboutSection(context, l10n),
              const SizedBox(height: AppDimens.spacingXL),
              _buildLogoutButton(context, ref, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    final avatarUrl = ref.watch(avatarUrlProvider);
    final uploadState = ref.watch(avatarUploadProvider);

    return CustomCard(
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadAvatar(context, ref),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: uploadState.status == AvatarUploadStatus.loading
                      ? const CircularProgressIndicator.adaptive()
                      : (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.camera_alt,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? 'email@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
                if (uploadState.status == AvatarUploadStatus.error)
                  Text(
                    uploadState.errorMessage ?? l10n.commonError,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar(
      BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    await ref
        .read(avatarUploadProvider.notifier)
        .upload(File(picked.path));
  }

  Widget _buildSettingsSection(BuildContext context, AppLocalizations l10n) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildListTile(context, Icons.currency_exchange, l10n.settingsCurrency, 'USD (\$)', onTap: () {}),
          const Divider(height: 1),
          _buildListTile(context, Icons.notifications_outlined, l10n.settingsNotifications, '', onTap: () => context.push('/settings/notifications')),
          const Divider(height: 1),
          _buildListTile(context, Icons.security, l10n.settingsPrivacySecurity, '', onTap: () => context.push('/settings/security')),
          const Divider(height: 1),
          _buildListTile(context, Icons.palette_outlined, l10n.settingsAppearance, '', onTap: () => context.push('/settings/appearance')),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildListTile(context, Icons.info_outline, l10n.settingsAbout, 'v1.0.0', onTap: () => context.push('/settings/about')),
          const Divider(height: 1),
          _buildListTile(context, Icons.help_outline, l10n.settingsHelp, '', onTap: () => context.push('/settings/help')),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, IconData icon, String title, String trailing,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(authNotifierProvider.notifier).logout();
          context.go('/login');
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(l10n.commonLogOut, style: const TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius)),
        ),
      ),
    );
  }
}
