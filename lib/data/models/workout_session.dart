import 'package:hive/hive.dart';

class WorkoutSession extends HiveObject {
  final String exerciseName;
  final int repCount;
  final int durationSeconds;
  final DateTime date;
  final String bodyPart;
  final double calories;
  final String exerciseId;

  WorkoutSession({
    required this.exerciseName,
    required this.repCount,
    required this.durationSeconds,
    required this.date,
    this.bodyPart = '',
    this.calories = 0.0,
    this.exerciseId = '',
  });
}

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 0;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      exerciseName: fields[0] as String,
      repCount: fields[1] as int,
      durationSeconds: fields[2] as int,
      date: fields[3] as DateTime,
      // fields 4-6 are absent in sessions saved before this schema version
      bodyPart: fields[4] as String? ?? '',
      calories: (fields[5] as num?)?.toDouble() ?? 0.0,
      exerciseId: fields[6] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.exerciseName)
      ..writeByte(1)
      ..write(obj.repCount)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.bodyPart)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
