import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/profile/profile_bloc.dart';
import 'package:my_shopping_mate/data/repositories/user_repository.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/primary_button.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/text_input_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The repository would be provided higher up the tree in a full app.
      create: (context) => ProfileBloc(userRepository: FakeUserRepository())
        // Dispatch the initial event to load the user's data.
        ..add(ProfileLoaded()),
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    
    // Dispatch the event to the BLoC with the new name.
    context.read<ProfileBloc>().add(ProfileNameChanged(_nameController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      // Use BlocConsumer to both listen for state changes (for side-effects
      // like SnackBars) and build the UI.
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          // Populate controllers when data loads or updates successfully.
          if (state.status == ProfileStatus.success || state.status == ProfileStatus.saveSuccess) {
            _nameController.text = state.user?.name ?? '';
            _emailController.text = state.user?.email ?? '';
          }

          // Listen for the successful save state to show a SnackBar.
          if (state.status == ProfileStatus.saveSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
          }
        },
        builder: (context, state) {
          // The UI should be shown for both success and saveSuccess states, but the loading indicator handles this.
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ProfileStatus.failure) {
            return const Center(child: Text('Failed to load profile.'));
          }

          // Main UI is built once the data is successfully loaded.
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... (Avatar Section remains the same) ...
                    const SizedBox(height: 40),
                    TextInputField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: Theme.of(context).inputDecorationTheme.border,
                      ),
                      ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: 'Save Changes',
                      // Button's loading state is now driven by the BLoC state.
                      isLoading: state.status == ProfileStatus.saving,
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}