import 'package:flutter/material.dart';

import '../services/employee_repository.dart';
import '../services/user_repository.dart';

/// Shows the add-employee form; returns `true` if an employee was created.
Future<bool> showAddEmployeeDialog(BuildContext context) async {
  final result = await showDialog<_AddEmployeeResult>(
    context: context,
    builder: (dialogContext) => _AddEmployeeDialog(hostContext: dialogContext),
  );

  if (result == null) return false;

  try {
    await EmployeeRepository.addEmployee(
      username: result.username,
      displayName: result.displayName,
      department: result.department,
      email: result.email,
      password: result.password,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Employee added. They can sign in with ${result.email} and the password you set.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      final message = switch (e) {
        ArgumentError() => e.message?.toString() ?? e.toString(),
        StateError() => e.message,
        _ => 'Could not add employee. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    return false;
  }
}

class _AddEmployeeResult {
  const _AddEmployeeResult({
    required this.username,
    required this.displayName,
    required this.department,
    required this.email,
    required this.password,
  });

  final String username;
  final String displayName;
  final String department;
  final String email;
  final String password;
}

class _AddEmployeeDialog extends StatefulWidget {
  const _AddEmployeeDialog({required this.hostContext});

  final BuildContext hostContext;

  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _dept = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _dept.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    final displayName = _name.text.trim();
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirmPassword.text;

    if (displayName.isEmpty || username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Full name, username, and email are required.')),
      );
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Enter a valid work email.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (password != confirm) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (!UserRepository.isValidUsername(username)) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Username must be 2–60 characters: letters, numbers, dots, dashes, or underscores.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _AddEmployeeResult(
        username: username,
        displayName: displayName,
        department: _dept.text.trim(),
        email: email,
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Employee'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Set a login password for the employee. They sign in on the Employee portal with their work email and this password.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dept,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Work Email *',
                hintText: 'employee@company.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _username,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Username *',
                hintText: 'e.g. jane.smith',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Login Password *',
                hintText: 'Min. 6 characters',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPassword,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirm Password *',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
