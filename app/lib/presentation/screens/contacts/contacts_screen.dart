import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animations/loading_animations.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/resources/themes/app_colors.dart';
import '../../../core/resources/themes/app_fonts.dart';
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
  final _clients = List<TraineeEntity>.empty(growable: true);
  final _filteredClients = List<TraineeEntity>.empty(growable: true);
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool isShowGridLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _filteredClients.clear();
        _filteredClients.addAll(
          _filterController(_searchController.text),
        );
      });
    });

    _scrollController.addListener(_scrollListener);

    GetIt.I<WorkoutAppointmentUsecase>()
        .getAllWorkoutAppointments()
        .then((value) => setState(() {
              final trainees =
                  value.appointments?.map((e) => e.trainee).toList() ?? [];
              _clients.clear();
              _clients.addAll(trainees);
              _filteredClients.clear();
              _filteredClients.addAll(trainees);
            }));
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BlocProvider.of<ContactsBloc>(context).add(GetContactsList());
      });
      // BlocProvider.of<ContactsBloc>(context).add(GetContactsList());
    }
  }

  List<TraineeEntity> _filterController(String query) {
    if (query.isEmpty) {
      return List.from(_clients);
    } else {
      return _clients.where((client) {
        final name = client.fullName;
        return name.contains(
          query.toLowerCase(),
        );
      }).toList();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final size = screenWidth > 600;
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Stack(
            children: [
              BlocBuilder<ContactsBloc, ContactsState>(
                builder: (context, state) {
                  if (state is ContactsSuccess ||
                      state is FindByNameSuccess ||
                      state is ContactsLoading) {
                    return size
                        ? GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 80),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            shrinkWrap: true,
                            itemCount: (state.clients?.length ?? 0) +
                                (state.hasMoreData! ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < (state.clients?.length ?? 0)) {
                                final trainee = state.clients?[index];
                                return GridContactsWidget(
                                  model: trainee!,
                                  onTap: () {
                                    context.read<ApplicationBloc>().add(
                                        SelectTraineeEvent(
                                            selectedTrainee: trainee));
                                    BlocProvider.of<ProgramScreenBloc>(context)
                                        .add(UpdateTraineeEvent(
                                            trainee: trainee));
                                    AutoRouter.of(context)
                                        .push(const ProgramRoute());
                                  },
                                );
                              } else {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: LoadingBouncingGrid.square(
                                      borderColor: AppColors.colorMain,
                                      borderSize: 3.0,
                                      size: 30.0,
                                      backgroundColor: AppColors.colorMain,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  ),
                                );
                              }
                            },
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isPortrait ? 3 : 4,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 0.0,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 50),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            shrinkWrap: state.clients?.isEmpty ?? true,
                            itemCount: (state.clients?.length ?? 0) +
                                (state.hasMoreData! ? 1 : 0),
                            itemBuilder: (context, index) {
                              debugPrint(
                                  'Index: $index, Clients length: ${state.clients?.length}, state is ${state.runtimeType}, state.hasMoreData: ${state.hasMoreData}');
                              if (index < (state.clients?.length ?? 0)) {
                                final trainee = state.clients?[index];
                                return ListContactsWidget(
                                  client: trainee!,
                                  onTap: () {
                                    context.read<ApplicationBloc>().add(
                                        SelectTraineeEvent(
                                            selectedTrainee: trainee));
                                    BlocProvider.of<ProgramScreenBloc>(context)
                                        .add(UpdateTraineeEvent(
                                            trainee: trainee));
                                    AutoRouter.of(context)
                                        .push(const ProgramRoute());
                                  },
                                );
                              } else {
                                return SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: LoadingBouncingGrid.square(
                                      borderColor: AppColors.colorMain,
                                      borderSize: 3.0,
                                      size: 30.0,
                                      backgroundColor: AppColors.colorMain,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                  }
                  if (state is ContactsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Please try againg later',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Try agaig'),
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: LoadingBouncingGrid.square(
                      borderColor: AppColors.colorMain,
                      borderSize: 3.0,
                      size: 30.0,
                      backgroundColor: AppColors.colorMain,
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle:
                      screenWidth > 600 ? AppFonts.w700s26 : AppFonts.w400s18,
                  fillColor: AppColors.colotSearch.withAlpha(235),
                  filled: true,
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.white,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.white,
                    ),
                  ),
                ),
                // controller: _searchController,
                onChanged: (value) => BlocProvider.of<ContactsBloc>(context)
                    .add(FindByNameContactsList(searchQuery: value)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
