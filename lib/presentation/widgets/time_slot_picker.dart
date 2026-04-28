import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// A single block of time that is already booked. The picker uses it both to
/// mark slots as occupied and to detect "won't fit" cases.
class BusyRange {
  final DateTime start;
  final DateTime end;

  /// Optional human-readable label (e.g. trainee name) shown next to the
  /// busy slot.
  final String? label;

  const BusyRange({required this.start, required this.end, this.label});
}

/// Show a bottom sheet that lets the coach pick a start time for a training
/// while seeing which parts of the day are already booked.
///
/// Returns the chosen [TimeOfDay] or `null` if cancelled.
Future<TimeOfDay?> showTimeSlotPicker(
  BuildContext context, {
  required DateTime date,
  required int durationMinutes,
  required List<BusyRange> busy,
  TimeOfDay? initial,
  TimeOfDay startOfDay = const TimeOfDay(hour: 6, minute: 0),
  TimeOfDay endOfDay = const TimeOfDay(hour: 22, minute: 0),
  int slotMinutes = 15,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.85,
      child: _TimeSlotPicker(
        date: date,
        durationMinutes: durationMinutes,
        busy: busy,
        initial: initial,
        startOfDay: startOfDay,
        endOfDay: endOfDay,
        slotMinutes: slotMinutes,
      ),
    ),
  );
}

enum _SlotState { free, busy, wontFit }

class _Slot {
  final DateTime start;
  final DateTime end;
  final _SlotState state;
  final BusyRange? busy;
  final BusyRange? blockingBusy; // for wontFit: what the session would crash into
  const _Slot({
    required this.start,
    required this.end,
    required this.state,
    this.busy,
    this.blockingBusy,
  });
}

class _TimeSlotPicker extends StatefulWidget {
  const _TimeSlotPicker({
    required this.date,
    required this.durationMinutes,
    required this.busy,
    required this.startOfDay,
    required this.endOfDay,
    required this.slotMinutes,
    this.initial,
  });

  final DateTime date;
  final int durationMinutes;
  final List<BusyRange> busy;
  final TimeOfDay? initial;
  final TimeOfDay startOfDay;
  final TimeOfDay endOfDay;
  final int slotMinutes;

  @override
  State<_TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<_TimeSlotPicker> {
  static const double _rowHeight = 56;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      // Anchor scroll near the initial selection if any, else 08:00, so the
      // user starts inside the "real" working hours instead of at 06:00.
      final anchor = widget.initial ?? const TimeOfDay(hour: 8, minute: 0);
      final minutesFromTop = (anchor.hour * 60 + anchor.minute) -
          (widget.startOfDay.hour * 60 + widget.startOfDay.minute);
      final slotIdx = (minutesFromTop / widget.slotMinutes).floor();
      final offset = math.max<double>(0, slotIdx * _rowHeight - 80);
      _scroll.jumpTo(math.min(offset, _scroll.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<_Slot> _buildSlots() {
    final dayStart = DateTime(widget.date.year, widget.date.month,
        widget.date.day, widget.startOfDay.hour, widget.startOfDay.minute);
    final dayEnd = DateTime(widget.date.year, widget.date.month, widget.date.day,
        widget.endOfDay.hour, widget.endOfDay.minute);
    final slotMs = Duration(minutes: widget.slotMinutes);
    final dur = Duration(minutes: widget.durationMinutes);
    final out = <_Slot>[];

    var cursor = dayStart;
    while (cursor.isBefore(dayEnd)) {
      final slotEnd = cursor.add(slotMs);

      // Does ANY busy range overlap the slot itself?
      BusyRange? containing;
      for (final b in widget.busy) {
        if (b.start.isBefore(slotEnd) && b.end.isAfter(cursor)) {
          containing = b;
          break;
        }
      }

      if (containing != null) {
        out.add(_Slot(
          start: cursor,
          end: slotEnd,
          state: _SlotState.busy,
          busy: containing,
        ));
        cursor = slotEnd;
        continue;
      }

      // Slot is free. Would the session that *starts* here also fit?
      final sessionEnd = cursor.add(dur);
      if (sessionEnd.isAfter(dayEnd)) {
        out.add(_Slot(start: cursor, end: slotEnd, state: _SlotState.wontFit));
        cursor = slotEnd;
        continue;
      }
      BusyRange? blocking;
      for (final b in widget.busy) {
        // Looking only at busy ranges that *start* during the would-be session
        // — anything that started earlier would already overlap the slot
        // itself and we'd have continued above.
        if (b.start.isBefore(sessionEnd) && b.start.isAtSameMomentAs(cursor) ||
            (b.start.isAfter(cursor) && b.start.isBefore(sessionEnd))) {
          blocking = b;
          break;
        }
      }
      if (blocking != null) {
        out.add(_Slot(
          start: cursor,
          end: slotEnd,
          state: _SlotState.wontFit,
          blockingBusy: blocking,
        ));
      } else {
        out.add(_Slot(start: cursor, end: slotEnd, state: _SlotState.free));
      }
      cursor = slotEnd;
    }
    return out;
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final slots = _buildSlots();
    final busyCount = widget.busy.length;
    final freeCount = slots.where((s) => s.state == _SlotState.free).length;

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pick start time',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Session: ${widget.durationMinutes} min  •  '
                      '$busyCount booked, $freeCount free slots',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6E6E6E)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // ── Legend ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Row(
            children: const [
              _LegendDot(color: Color(0xFFE6F4EA), label: 'Free'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFFEEBEE), label: 'Booked'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFFFF8E1), label: 'Won\'t fit'),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEDEDED)),
        // ── Slots list ─────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            itemCount: slots.length,
            itemBuilder: (context, i) {
              final s = slots[i];
              return _SlotRow(
                height: _rowHeight,
                timeLabel: _fmt(s.start),
                state: s.state,
                trailing: _trailingFor(s),
                isSelected: widget.initial != null &&
                    widget.initial!.hour == s.start.hour &&
                    widget.initial!.minute == s.start.minute,
                onTap: s.state == _SlotState.free
                    ? () => Navigator.of(context).pop(
                          TimeOfDay(hour: s.start.hour, minute: s.start.minute),
                        )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  String _trailingFor(_Slot s) {
    switch (s.state) {
      case _SlotState.free:
        final endIfPicked = s.start
            .add(Duration(minutes: widget.durationMinutes));
        return '→ ${_fmt(endIfPicked)}';
      case _SlotState.busy:
        final b = s.busy!;
        final range = '${_fmt(b.start)}–${_fmt(b.end)}';
        return b.label != null && b.label!.isNotEmpty
            ? '$range  •  ${b.label}'
            : range;
      case _SlotState.wontFit:
        if (s.blockingBusy != null) {
          return 'next at ${_fmt(s.blockingBusy!.start)}';
        }
        return 'past closing';
    }
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.height,
    required this.timeLabel,
    required this.state,
    required this.trailing,
    required this.isSelected,
    required this.onTap,
  });

  final double height;
  final String timeLabel;
  final _SlotState state;
  final String trailing;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _SlotState.free => isSelected ? const Color(0xFF1E1E1E) : Colors.white,
      _SlotState.busy => const Color(0xFFFEEBEE),
      _SlotState.wontFit => const Color(0xFFFFF8E1),
    };
    final fg = switch (state) {
      _SlotState.free =>
        isSelected ? Colors.white : const Color(0xFF1E1E1E),
      _SlotState.busy => const Color(0xFFB42318),
      _SlotState.wontFit => const Color(0xFF8A6D00),
    };
    final trailingFg = switch (state) {
      _SlotState.free =>
        isSelected ? Colors.white70 : const Color(0xFF6E6E6E),
      _SlotState.busy => const Color(0xFFB42318),
      _SlotState.wontFit => const Color(0xFF8A6D00),
    };

    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bg,
          border: const Border(
            bottom: BorderSide(color: Color(0xFFF1F1F1), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                trailing,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: trailingFg),
              ),
            ),
            if (state == _SlotState.free && !isSelected)
              const Icon(FIcons.chevronRight,
                  size: 16, color: Color(0xFF9E9E9E)),
            if (isSelected)
              const Icon(FIcons.circleCheck, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Color(0xFF6E6E6E))),
      ],
    );
  }
}
