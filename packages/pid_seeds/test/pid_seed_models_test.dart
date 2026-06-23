import 'package:flutter_test/flutter_test.dart';
import 'package:pid_seeds/pid_seeds.dart';

void main() {
  test('PidStopData copyWith keeps existing values', () {
    const stop = PidStopData(
      id: 'stop-1',
      name: 'Hradčanská',
      subtitle: 'tram',
      transportType: PidTransportType.tram,
    );

    final updated = stop.copyWith(name: 'Staroměstská');

    expect(updated.id, 'stop-1');
    expect(updated.name, 'Staroměstská');
    expect(updated.transportType, PidTransportType.tram);
  });

  test('PidDepartureData detects delay', () {
    const departure = PidDepartureData(
      id: 'dep-1',
      lineLabel: '8',
      destination: 'Starý Hloubětín',
      remainingTimeText: '5',
      delayText: '+2',
    );

    expect(departure.isDelayed, isTrue);
  });
}
