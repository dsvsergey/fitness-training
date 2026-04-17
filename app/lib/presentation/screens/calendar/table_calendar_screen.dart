import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../widgets/button_widget.dart';

@RoutePage()
class TableCalendarScreen extends StatefulWidget {
  final DateTime currentDate;
  final List<DateTime> workDays;
  const TableCalendarScreen({
    super.key,
    required this.currentDate,
    required this.workDays,
  });

  @override
  State<TableCalendarScreen> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime today = DateTime.now();
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDate;
    today = widget.currentDate;
    _focusedDay = widget.currentDate;
  }

  void _onDaySelectedA(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      _selectedDay = day;
      _focusedDay = focusedDay;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _rangeStart = start;
      _rangeEnd = end;
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
            onPressed: () => context.router.pop<DateTime?>(_selectedDay),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            if (isTablet) const SizedBox(height: 70),
            Padding(
              padding: isTablet
                  ? const EdgeInsets.all(20)
                  : const EdgeInsets.all(10),
              child: TableCalendar(
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekHeight: 40,
                locale: 'en_US',
                rowHeight: isTablet ? 72 : 48,
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 36.0 : 20.0,
                  ),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF1E1E1E),
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                onDaySelected: _onDaySelectedA,
                eventLoader: (day) => widget.workDays
                        .where((d) => isSameDay(d, day))
                        .isNotEmpty
                    ? ['Event']
                    : [],
                rangeStartDay: _rangeStart,
                rangeSelectionMode: RangeSelectionMode.toggledOff,
                onRangeSelected: _onRangeSelected,
                rangeEndDay: _rangeEnd,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: const Color(0xFF1E1E1E),
                    fontSize: isTablet ? 18.0 : 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: const Color(0xFF9E9E9E),
                    fontSize: isTablet ? 18.0 : 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: const Color(0xFF1E1E1E),
                    fontSize: isTablet ? 26.0 : 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  weekNumberTextStyle:
                      const TextStyle(color: Color(0xFF1E1E1E)),
                  weekendTextStyle: TextStyle(
                    color: const Color(0xFF9E9E9E),
                    fontSize: isTablet ? 26.0 : 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  rangeHighlightColor: const Color(0xFFE0E0E0),
                  isTodayHighlighted: true,
                  canMarkersOverflow: false,
                  outsideDaysVisible: false,
                  markersAutoAligned: false,
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 26.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: const Color(0xFF1E1E1E),
                    fontSize: isTablet ? 26.0 : 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  todayDecoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E1E1E),
                      width: 1.5,
                    ),
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                  rangeStartTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 26.0 : 16.0,
                  ),
                  rangeEndTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 26.0 : 16.0,
                  ),
                  rangeEndDecoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
              ),
            ),
            const Spacer(),
            ButtonWidget(
              onPressed: () => context.router.pop<DateTime?>(_selectedDay),
              title: 'Show Results',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
