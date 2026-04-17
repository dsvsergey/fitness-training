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
import '../programs/program_screen/bloc/program_screen_bloc.dart';
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

    // Forward controller changes to BLoC
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
    BlocProvider.of<ProgramScreenBloc>(context)
        .add(UpdateTraineeEvent(trainee: trainee));
    AutoRouter.of(context).push(const ProgramRoute());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
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
                          return const Center(
                            child: FCircularProgress(),
                          );
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
              FTextField(
                control: FTextFieldControl.managed(
                  controller: _searchController,
                ),
                hint: 'Search',
                prefixBuilder: (_, __, ___) => const Icon(FIcons.search),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
