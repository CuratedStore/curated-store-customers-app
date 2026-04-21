import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/models.dart';
import '../../shared/brand_widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  final _addressLabel = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressCity = TextEditingController();
  final _addressState = TextEditingController();
  final _addressPincode = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nameController = TextEditingController(text: state.profile.name);
    _emailController = TextEditingController(text: state.profile.email);
    _phoneController = TextEditingController(text: state.profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLabel.dispose();
    _addressLine1.dispose();
    _addressCity.dispose();
    _addressState.dispose();
    _addressPincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const BrandHeader(
              title: 'Account & Preferences',
              subtitle: 'Manage profile, addresses, and communication settings.',
            ),
            const SizedBox(height: 16),
            _buildProfileCard(state),
            const SizedBox(height: 12),
            _buildAddressCard(state),
            const SizedBox(height: 12),
            _buildPreferencesCard(state),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                OutlinedButton(
                  onPressed: state.loading ? null : state.bootstrap,
                  child: const Text('Refresh API Status'),
                ),
                OutlinedButton(
                  onPressed: state.loading ? null : state.signOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(state.statusMessage),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard(AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Profile', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => state.updateProfile(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Address Book',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...state.addresses.map((address) => _addressTile(state, address)),
            const Divider(height: 22),
            TextField(
              controller: _addressLabel,
              decoration: const InputDecoration(labelText: 'Label (Home/Office)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressLine1,
              decoration: const InputDecoration(labelText: 'Address line'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _addressCity,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _addressState,
                    decoration: const InputDecoration(labelText: 'State'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressPincode,
              decoration: const InputDecoration(labelText: 'Pincode'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_addressLabel.text.trim().isEmpty ||
                    _addressLine1.text.trim().isEmpty ||
                    _addressCity.text.trim().isEmpty ||
                    _addressState.text.trim().isEmpty ||
                    _addressPincode.text.trim().isEmpty) {
                  return;
                }
                state.addAddress(
                  label: _addressLabel.text.trim(),
                  line1: _addressLine1.text.trim(),
                  city: _addressCity.text.trim(),
                  state: _addressState.text.trim(),
                  pincode: _addressPincode.text.trim(),
                );
                _addressLabel.clear();
                _addressLine1.clear();
                _addressCity.clear();
                _addressState.clear();
                _addressPincode.clear();
              },
              child: const Text('Add Address'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressTile(AppState state, Address address) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${address.label}${address.isDefault ? ' (Default)' : ''}'),
      subtitle: Text('${address.line1}, ${address.city}, ${address.state} - ${address.pincode}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!address.isDefault)
            IconButton(
              onPressed: () => state.setDefaultAddress(address),
              icon: const Icon(Icons.check_circle_outline),
            ),
          IconButton(
            onPressed: () => state.deleteAddress(address),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Preferences', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: state.preferences.currency,
              decoration: const InputDecoration(labelText: 'Currency'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'INR', child: Text('INR')),
                DropdownMenuItem(value: 'USD', child: Text('USD')),
                DropdownMenuItem(value: 'EUR', child: Text('EUR')),
              ],
              onChanged: (value) {
                if (value != null) {
                  state.updatePreferences(
                    currency: value,
                    language: state.preferences.language,
                    emailNotifications: state.preferences.emailNotifications,
                    smsNotifications: state.preferences.smsNotifications,
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: state.preferences.language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'hi', child: Text('Hindi')),
              ],
              onChanged: (value) {
                if (value != null) {
                  state.updatePreferences(
                    currency: state.preferences.currency,
                    language: value,
                    emailNotifications: state.preferences.emailNotifications,
                    smsNotifications: state.preferences.smsNotifications,
                  );
                }
              },
            ),
            SwitchListTile(
              value: state.preferences.emailNotifications,
              title: const Text('Email Notifications'),
              onChanged: (value) => state.updatePreferences(
                currency: state.preferences.currency,
                language: state.preferences.language,
                emailNotifications: value,
                smsNotifications: state.preferences.smsNotifications,
              ),
            ),
            SwitchListTile(
              value: state.preferences.smsNotifications,
              title: const Text('SMS Notifications'),
              onChanged: (value) => state.updatePreferences(
                currency: state.preferences.currency,
                language: state.preferences.language,
                emailNotifications: state.preferences.emailNotifications,
                smsNotifications: value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
