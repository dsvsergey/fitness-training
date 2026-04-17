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
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDate;
    today = widget.currentDate;
  }

  void _onDaySelectedA(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      _selectedDay = day;
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
                daysOfWeekHeight: 50,
                locale: 'en_US',
                rowHeight: isTablet ? 76 : 46,
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 40.0 : 25.0,
                  ),
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: widget.currentDate,
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
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 30.0 : 22.0,
                  ),
                  weekNumberTextStyle:
                      const TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(
                    color: Colors.red,
                    fontSize: isTablet ? 30.0 : 22.0,
                  ),
                  rangeHighlightColor:
                      const Color.fromARGB(255, 229, 233, 112),
                  isTodayHighlighted: false,
                  canMarkersOverflow: false,
                  outsideDaysVisible: false,
                  markersAutoAligned: false,
                  selectedTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 32.0 : 23.0,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Color(0xFFC8CE37),
                    shape: BoxShape.circle,
                  ),
                  rangeStartTextStyle: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 16.0,
                  ),
                  rangeEndDecoration: const BoxDecoration(
                    color: Color(0xFFC8CE37),
                    shape: BoxShape.circle,
                  ),
                  rangeStartDecoration: const BoxDecoration(
                    color: Color(0xFFC8CE37),
                    shape: BoxShape.circle,
                  ),
                  rangeEndTextStyle: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 16.0,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    backgroundColor: Color(0xFF1E1E1E),
                    decorationColor: Colors.green,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
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
