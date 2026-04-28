import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../domain/entities/fitness/fitness.dart';

@RoutePage()
class ArchieveProgramScreen extends StatefulWidget {
  const ArchieveProgramScreen({
    super.key,
    required this.machines,
  });
  final List<MachineEntity> machines;

  @override
  State<ArchieveProgramScreen> createState() => _ArchieveProgramScreenState();
}

class _ArchieveProgramScreenState extends State<ArchieveProgramScreen> {
  final List<MachineEntity> _selectedMachines = [];

  void _removeSelectedApparatus() {
    setState(() {
      widget.machines
          .removeWhere((m) => _selectedMachines.contains(m));
      _selectedMachines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: context.theme.colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(FIcons.arrowLeft, color: context.theme.colors.foreground),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          Text(
            'Program A',
            textAlign: TextAlign.center,
            style: context.theme.typography.xl2
                .copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          Wrap(
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: widget.machines.map((machine) {
              final isSelected = _selectedMachines.contains(machine);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedMachines.remove(machine);
                  } else {
                    _selectedMachines.add(machine);
                  }
                }),
                child: Container(
                  width: isTablet ? 130 : 65,
                  height: isTablet ? 110 : 55,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.colors.primary
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      machine.name,
                      style: TextStyle(
                        color: isSelected
                            ? context.theme.colors.primaryForeground
                            : context.theme.colors.foreground,
                        fontSize: isTablet ? 80 : 40,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: isTablet ? 350 : 160,
                  child: FButton(
                    onPress: _removeSelectedApparatus,
                    variant: FButtonVariant.destructive,
                    child: const Text('Restore'),
                  ),
                ),
                SizedBox(
                  width: isTablet ? 350 : 160,
                  child: FButton(
                    onPress: () {},
                    child: const Text('Restore'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
