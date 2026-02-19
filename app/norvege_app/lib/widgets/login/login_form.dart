import 'package:flutter/material.dart';
import 'package:norvege_app/theme.dart';
import 'package:norvege_app/widgets/login/login_text_field.dart';
import 'package:norvege_app/widgets/login/section_title.dart';
import '../../l10n/app_localizations.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final TextEditingController objectiveController;
  final String selectedLevel;
  final List<String> levels;
  final List<String> allModes;
  final List<String> selectedModes;
  final bool isLogin;
  final bool isLoading;
  final Function(String) onLevelChanged;
  final Function(bool, String) onModeSelected;
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameController,
    required this.objectiveController,
    required this.selectedLevel,
    required this.levels,
    required this.allModes,
    required this.selectedModes,
    required this.isLogin,
    required this.isLoading,
    required this.onLevelChanged,
    required this.onModeSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLogin) ...[
            SectionTitle(title: l10n.loginAboutYou),
            const SizedBox(height: 8),
            LoginTextField(
              controller: nameController,
              label: l10n.loginPseudo,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedLevel,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.loginEstimatedLevel,
                prefixIcon: const Icon(
                  Icons.bar_chart,
                  color: AppColors.deepBlue,
                ),
                filled: true,
                fillColor: AppColors.softGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: levels
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(l, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (val) => onLevelChanged(val!),
            ),
            const SizedBox(height: 12),
            LoginTextField(
              controller: objectiveController,
              label: l10n.loginObjectiveExample,
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 16),
            SectionTitle(title: l10n.loginPreferredStyles),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allModes.map((mode) {
                final isSelected = selectedModes.contains(mode);
                return FilterChip(
                  label: Text(mode),
                  selected: isSelected,
                  onSelected: (selected) {
                    onModeSelected(selected, mode);
                  },
                  selectedColor: AppColors.vibrantOrange.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.vibrantOrange,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.vibrantOrange
                        : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
          ],
          LoginTextField(
            controller: emailController,
            label: l10n.loginEmail,
            icon: Icons.email_outlined,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          LoginTextField(
            controller: passwordController,
            label: l10n.loginPassword,
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          if (!isLogin) ...[
            const SizedBox(height: 12),
            LoginTextField(
              controller: confirmPasswordController,
              label: l10n.loginConfirmPassword,
              icon: Icons.check_circle_outline,
              isPassword: true,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isLogin ? l10n.loginConnect : l10n.loginValidateProfile,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
