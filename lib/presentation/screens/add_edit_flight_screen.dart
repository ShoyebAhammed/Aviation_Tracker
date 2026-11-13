import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/flight_model.dart';
import '../providers/flight_provider.dart';

class AddEditFlightScreen extends StatefulWidget {
  final FlightModel? flight;

  const AddEditFlightScreen({super.key, this.flight});

  @override
  State<AddEditFlightScreen> createState() => _AddEditFlightScreenState();
}

class _AddEditFlightScreenState extends State<AddEditFlightScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _flightNumberController;
  late TextEditingController _airlineController;
  late TextEditingController _depIataController;
  late TextEditingController _depAirportController;
  late TextEditingController _depTerminalController;
  late TextEditingController _depGateController;
  late TextEditingController _arrIataController;
  late TextEditingController _arrAirportController;
  late TextEditingController _arrTerminalController;
  late TextEditingController _arrGateController;
  late TextEditingController _seatController;
  late TextEditingController _notesController;

  String _status = 'scheduled';
  DateTime _depDate = DateTime.now().add(const Duration(hours: 2));
  DateTime _arrDate = DateTime.now().add(const Duration(hours: 6));

  final List<String> _statusOptions = [
    'scheduled',
    'active',
    'landed',
    'delayed',
    'cancelled',
    'diverted',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.flight;
    _flightNumberController = TextEditingController(text: f?.flightNumberDisplay ?? '');
    _airlineController = TextEditingController(text: f?.airlineNameDisplay ?? '');
    _depIataController = TextEditingController(text: f?.departure.iata ?? 'SFO');
    _depAirportController = TextEditingController(text: f?.departure.airport ?? 'San Francisco International');
    _depTerminalController = TextEditingController(text: f?.departure.terminal ?? '2');
    _depGateController = TextEditingController(text: f?.departure.gate ?? 'D11');

    _arrIataController = TextEditingController(text: f?.arrival.iata ?? 'JFK');
    _arrAirportController = TextEditingController(text: f?.arrival.airport ?? 'John F Kennedy International');
    _arrTerminalController = TextEditingController(text: f?.arrival.terminal ?? '4');
    _arrGateController = TextEditingController(text: f?.arrival.gate ?? 'B24');

    _seatController = TextEditingController(text: f?.passengerSeat ?? '12A');
    _notesController = TextEditingController(text: f?.userNotes ?? '');

    if (f != null) {
      _status = f.flightStatus.toLowerCase();
      if (f.departure.scheduled != null) {
        _depDate = DateTime.tryParse(f.departure.scheduled!) ?? _depDate;
      }
      if (f.arrival.scheduled != null) {
        _arrDate = DateTime.tryParse(f.arrival.scheduled!) ?? _arrDate;
      }
    }
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _airlineController.dispose();
    _depIataController.dispose();
    _depAirportController.dispose();
    _depTerminalController.dispose();
    _depGateController.dispose();
    _arrIataController.dispose();
    _arrAirportController.dispose();
    _arrTerminalController.dispose();
    _arrGateController.dispose();
    _seatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isDeparture) async {
    final current = isDeparture ? _depDate : _arrDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null || !mounted) return;

    final result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isDeparture) {
        _depDate = result;
      } else {
        _arrDate = result;
      }
    });
  }

  void _saveFlight() {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.flight != null;
    final flightId = widget.flight?.id ?? const Uuid().v4();

    final flightModel = FlightModel(
      id: flightId,
      flightDate: DateFormat('yyyy-MM-dd').format(_depDate),
      flightStatus: _status,
      isCustom: true,
      isFavorite: widget.flight?.isFavorite ?? false,
      userNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      passengerSeat: _seatController.text.trim().isEmpty ? null : _seatController.text.trim(),
      airline: AirlineModel(
        name: _airlineController.text.trim(),
        iata: _flightNumberController.text.trim().length >= 2
            ? _flightNumberController.text.trim().substring(0, 2).toUpperCase()
            : null,
      ),
      flight: FlightInfoModel(
        number: _flightNumberController.text.trim(),
        iata: _flightNumberController.text.trim().toUpperCase(),
      ),
      departure: DepartureModel(
        iata: _depIataController.text.trim().toUpperCase(),
        airport: _depAirportController.text.trim(),
        terminal: _depTerminalController.text.trim(),
        gate: _depGateController.text.trim(),
        scheduled: _depDate.toIso8601String(),
        actual: _status == 'active' || _status == 'landed' ? _depDate.toIso8601String() : null,
      ),
      arrival: ArrivalModel(
        iata: _arrIataController.text.trim().toUpperCase(),
        airport: _arrAirportController.text.trim(),
        terminal: _arrTerminalController.text.trim(),
        gate: _arrGateController.text.trim(),
        scheduled: _arrDate.toIso8601String(),
        estimated: _arrDate.toIso8601String(),
      ),
    );

    final provider = context.read<FlightProvider>();
    if (isEditing) {
      provider.updateFlight(flightModel);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight updated successfully!')),
      );
    } else {
      provider.createFlight(flightModel);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flight created and tracked locally!')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.flight != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Flight' : 'Track Custom Flight'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.radarCyan),
            onPressed: _saveFlight,
            tooltip: 'Save Flight',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Flight & Airline Section
            _sectionHeader('Flight Identification'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _flightNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Flight Number *',
                      hintText: 'e.g. EK 204 or DL415',
                      prefixIcon: Icon(Icons.flight),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _airlineController,
                    decoration: const InputDecoration(
                      labelText: 'Airline Name *',
                      hintText: 'e.g. Emirates',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status Dropdown
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Flight Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _statusOptions.map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Text(st.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),

            const SizedBox(height: 24),

            // Departure Information
            _sectionHeader('Departure (Origin)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _depIataController,
                    decoration: const InputDecoration(
                      labelText: 'Origin IATA *',
                      hintText: 'SFO',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _depAirportController,
                    decoration: const InputDecoration(
                      labelText: 'Airport Name',
                      hintText: 'San Francisco Int\'l',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _depTerminalController,
                    decoration: const InputDecoration(labelText: 'Terminal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _depGateController,
                    decoration: const InputDecoration(labelText: 'Gate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.access_time),
              title: const Text('Departure Time'),
              subtitle: Text(DateFormat('MMM d, yyyy  h:mm a').format(_depDate)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _pickDateTime(true),
            ),

            const SizedBox(height: 24),

            // Arrival Information
            _sectionHeader('Arrival (Destination)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _arrIataController,
                    decoration: const InputDecoration(
                      labelText: 'Dest IATA *',
                      hintText: 'JFK',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _arrAirportController,
                    decoration: const InputDecoration(
                      labelText: 'Airport Name',
                      hintText: 'John F Kennedy Int\'l',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _arrTerminalController,
                    decoration: const InputDecoration(labelText: 'Terminal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _arrGateController,
                    decoration: const InputDecoration(labelText: 'Gate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              leading: const Icon(Icons.access_time_filled),
              title: const Text('Arrival Time'),
              subtitle: Text(DateFormat('MMM d, yyyy  h:mm a').format(_arrDate)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () => _pickDateTime(false),
            ),

            const SizedBox(height: 24),

            // Additional Custom Tracking Fields
            _sectionHeader('Passenger & Personal Notes'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _seatController,
              decoration: const InputDecoration(
                labelText: 'Seat Number',
                hintText: 'e.g. 14A or 32B',
                prefixIcon: Icon(Icons.airline_seat_recline_extra),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Personal Notes / Reminders',
                hintText: 'e.g. Pick up at baggage claim 4, family arriving',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveFlight,
              icon: const Icon(Icons.save),
              label: Text(
                isEditing ? 'UPDATE FLIGHT' : 'SAVE & TRACK FLIGHT',
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.radarCyan,
        letterSpacing: 0.8,
      ),
    );
  }
}
