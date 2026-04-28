import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/fitness.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../widgets/grid_contacts_widget.dart';
import '../../widgets/list_contacts_widget.dart';
import 'bloc/contacts_bloc.dart';

@RoutePage()
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _clients = <TraineeEntity>[];
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      BlocProvider.of<ContactsBloc>(context).add(
        FindByNameContactsList(searchQuery: _searchController.text),
      );
    });

    _scrollController.addListener(_scrollListener);

    GetIt.I<WorkoutAppointmentUsecase>()
        .getAllWorkoutAppointments()
        .then((value) {
      if (!mounted) return;
      setState(() {
        final trainees =
            value.appointments?.map((e) => e.trainee).toList() ?? [];
        _clients
          ..clear()
          ..addAll(trainees);
      });
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          BlocProvider.of<ContactsBloc>(context).add(GetContactsList());
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openClient(BuildContext context, TraineeEntity trainee) {
    context
        .read<ApplicationBloc>()
        .add(SelectTraineeEvent(selectedTrainee: trainee));
    AutoRouter.of(context).push(ContactDetailRoute(trainee: trainee));
  }

  void _showTraineeForm(BuildContext context, {TraineeEntity? trainee}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<ContactsBloc>(context),
        child: _TraineeFormSheet(trainee: trainee),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TraineeEntity trainee) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete trainee',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        content: Text(
          'Remove ${trainee.fullName}? This cannot be undone.',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6E6E6E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6E6E6E)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (trainee.id != null) {
                BlocProvider.of<ContactsBloc>(context)
                    .add(DeleteTraineeEvent(traineeId: trainee.id!));
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'contacts_fab',
        onPressed: () => _showTraineeForm(context),
        backgroundColor: const Color(0xFF1E1E1E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              // ── Contact list / grid ─────────────────────────────────────
              BlocBuilder<ContactsBloc, ContactsState>(
                builder: (context, state) {
                  if (state is ContactsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Something went wrong',
                            style: context.theme.typography.md
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FButton(
                            onPress: () => BlocProvider.of<ContactsBloc>(
                              context,
                            ).add(GetContactsList()),
                            variant: FButtonVariant.outline,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ContactsSuccess ||
                      state is FindByNameSuccess ||
                      state is ContactsLoading) {
                    final clients = state.clients ?? [];
                    final hasMore = state.hasMoreData ?? false;
                    final itemCount = clients.length + (hasMore ? 1 : 0);

                    if (clients.isEmpty && state is! ContactsLoading) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline,
                                size: 64, color: Color(0xFFBDBDBD)),
                            SizedBox(height: 16),
                            Text(
                              'No contacts yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap + to add your first trainee',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (isTablet) {
                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 72),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        shrinkWrap: true,
                        itemCount: itemCount,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isPortrait ? 3 : 4,
                        ),
                        itemBuilder: (context, index) {
                          if (index < clients.length) {
                            return GridContactsWidget(
                              model: clients[index],
                              onTap: () =>
                                  _openClient(context, clients[index]),
                            );
                          }
                          return const Center(child: FCircularProgress());
                        },
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 72),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      shrinkWrap: clients.isEmpty,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index < clients.length) {
                          return ListContactsWidget(
                            client: clients[index],
                            onTap: () =>
                                _openClient(context, clients[index]),
                            onEdit: () => _showTraineeForm(context,
                                trainee: clients[index]),
                            onDelete: () =>
                                _confirmDelete(context, clients[index]),
                          );
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: FCircularProgress(),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(child: FCircularProgress());
                },
              ),

              // ── Search bar ──────────────────────────────────────────────
              TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E1E1E),
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trainee create / edit form ────────────────────────────────────────────────

class _TraineeFormSheet extends StatefulWidget {
  final TraineeEntity? trainee;

  const _TraineeFormSheet({this.trainee});

  @override
  State<_TraineeFormSheet> createState() => _TraineeFormSheetState();
}

class _TraineeFormSheetState extends State<_TraineeFormSheet> {
  bool get _isEdit => widget.trainee != null;

  late final _firstNameCtrl =
      TextEditingController(text: widget.trainee?.firstName ?? '');
  late final _lastNameCtrl =
      TextEditingController(text: widget.trainee?.lastName ?? '');
  late final _emailCtrl =
      TextEditingController(text: widget.trainee?.email ?? '');
  late final _passwordCtrl = TextEditingController();
  late final _phoneCtrl =
      TextEditingController(text: widget.trainee?.mobilePhone ?? '');
  late final _weightCtrl = TextEditingController(
      text: widget.trainee?.weight?.toString() ?? '');
  late final _heightCtrl = TextEditingController(
      text: widget.trainee?.height?.toString() ?? '');
  late final _notesCtrl =
      TextEditingController(text: widget.trainee?.notes ?? '');

  String? _error;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      setState(() => _error = 'First name, last name and email are required.');
      return;
    }
    if (!_isEdit && password.isEmpty) {
      setState(() => _error = 'Password is required for new trainee.');
      return;
    }

    final trainee = TraineeEntity((b) => b
      ..id = widget.trainee?.id
      ..firstName = firstName
      ..lastName = lastName
      ..email = email
      ..mobilePhone =
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim()
      ..weight = double.tryParse(_weightCtrl.text.trim())
      ..height = double.tryParse(_heightCtrl.text.trim())
      ..notes =
          _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());

    final bloc = BlocProvider.of<ContactsBloc>(context);

    if (_isEdit) {
      bloc.add(UpdateTraineeContactEvent(
        traineeId: widget.trainee!.id!,
        trainee: trainee,
      ));
    } else {
      bloc.add(CreateTraineeEvent(
        trainee: trainee,
        password: password,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEdit ? 'Edit Trainee' : 'New Trainee',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _Field(
                        label: 'First name *',
                        controller: _firstNameCtrl)),
                const SizedBox(width: 12),
                Expanded(
                    child: _Field(
                        label: 'Last name *',
                        controller: _lastNameCtrl)),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Email *',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 12),
              _Field(
                label: 'Password *',
                controller: _passwordCtrl,
                obscureText: true,
              ),
            ],
            const SizedBox(height: 12),
            _Field(
              label: 'Phone',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _Field(
                        label: 'Weight (kg)',
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 12),
                Expanded(
                    child: _Field(
                        label: 'Height (cm)',
                        controller: _heightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true))),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Notes',
              controller: _notesCtrl,
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFD32F2F)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                        _isEdit ? 'Save changes' : 'Create trainee',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6E6E),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E1E1E)),
            ),
          ),
        ),
      ],
    );
  }
}
