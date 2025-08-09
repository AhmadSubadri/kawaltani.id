// File: lib/models/dashboard_data.dart
class DashboardData {
  final List<Sensor>? nitrogen;
  final List<Sensor>? fosfor;
  final List<Sensor>? kalium;
  final List<Sensor>? soilPh;
  final List<EnvironmentData>? temperature;
  final List<EnvironmentData>? humidity;
  final List<EnvironmentData>? wind;
  final List<EnvironmentData>? lux;
  final List<EnvironmentData>? rain;
  final List<Plant>? plants;
  final List<TodoGroup>? todos;
  final String? lastUpdated;
  final List<Device>? devices;

  DashboardData({
    this.nitrogen,
    this.fosfor,
    this.kalium,
    this.soilPh,
    this.temperature,
    this.humidity,
    this.wind,
    this.lux,
    this.rain,
    this.plants,
    this.todos,
    this.lastUpdated,
    this.devices,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      nitrogen:
          json['nitrogen'] != null
              ? (json['nitrogen'] as List)
                  .map((e) => Sensor.fromJson(e))
                  .toList()
              : null,
      fosfor:
          json['fosfor'] != null
              ? (json['fosfor'] as List).map((e) => Sensor.fromJson(e)).toList()
              : null,
      kalium:
          json['kalium'] != null
              ? (json['kalium'] as List).map((e) => Sensor.fromJson(e)).toList()
              : null,
      soilPh:
          json['soil_ph'] != null
              ? (json['soil_ph'] as List)
                  .map((e) => Sensor.fromJson(e))
                  .toList()
              : null,
      temperature:
          json['temperature'] != null
              ? (json['temperature'] as List)
                  .map((e) => EnvironmentData.fromJson(e))
                  .toList()
              : null,
      humidity:
          json['humidity'] != null
              ? (json['humidity'] as List)
                  .map((e) => EnvironmentData.fromJson(e))
                  .toList()
              : null,
      wind:
          json['wind'] != null
              ? (json['wind'] as List)
                  .map((e) => EnvironmentData.fromJson(e))
                  .toList()
              : null,
      lux:
          json['lux'] != null
              ? (json['lux'] as List)
                  .map((e) => EnvironmentData.fromJson(e))
                  .toList()
              : null,
      rain:
          json['rain'] != null
              ? (json['rain'] as List)
                  .map((e) => EnvironmentData.fromJson(e))
                  .toList()
              : null,
      plants:
          json['plants'] != null
              ? (json['plants'] as List).map((e) => Plant.fromJson(e)).toList()
              : null,
      todos:
          json['todos'] != null
              ? (json['todos'] as List)
                  .map((e) => TodoGroup.fromJson(e))
                  .toList()
              : null,
      lastUpdated: json['last_updated'],
      devices:
          json['devices'] != null
              ? (json['devices'] as List)
                  .map((e) => Device.fromJson(e))
                  .toList()
              : null,
    );
  }
}

class Sensor {
  final String sensor;
  final String sensorName;
  final String readValue;
  final String readDate;
  final String valueStatus;
  final String statusMessage;
  final String? actionMessage;

  Sensor({
    required this.sensor,
    required this.sensorName,
    required this.readValue,
    required this.readDate,
    required this.valueStatus,
    required this.statusMessage,
    this.actionMessage,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      sensor: json['sensor'] ?? '',
      sensorName: json['sensor_name'] ?? '',
      readValue: json['read_value'].toString(),
      readDate: json['read_date'] ?? '',
      valueStatus: json['value_status'] ?? '',
      statusMessage: json['status_message'] ?? '',
      actionMessage: json['action_message'],
    );
  }
}

class EnvironmentData {
  final String sensor;
  final double readValue;
  final String? readDate;
  final String? valueStatus;
  final String? statusMessage;
  final String? actionMessage;
  final String? sensorName;

  EnvironmentData({
    required this.sensor,
    required this.readValue,
    this.readDate,
    this.valueStatus,
    this.statusMessage,
    this.actionMessage,
    this.sensorName,
  });

  factory EnvironmentData.fromJson(Map<String, dynamic> json) {
    return EnvironmentData(
      sensor: json['sensor'] ?? '',
      readValue: double.parse(json['read_value'].toString()),
      readDate: json['read_date'],
      valueStatus: json['value_status'],
      statusMessage: json['status_message'],
      actionMessage: json['action_message'],
      sensorName: json['sensor_name'],
    );
  }
}

class Plant {
  final String plId;
  final String plName;
  final String plDesc;
  final String plDatePlanting;
  final int age;
  final String phase;
  final int timeToHarvest;
  final String commodity;
  final String variety;

  Plant({
    required this.plId,
    required this.plName,
    required this.plDesc,
    required this.plDatePlanting,
    required this.age,
    required this.phase,
    required this.timeToHarvest,
    required this.commodity,
    required this.variety,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plId: json['pl_id'] ?? '',
      plName: json['pl_name'] ?? '',
      plDesc: json['pl_desc'] ?? '',
      plDatePlanting: json['pl_date_planting'] ?? '',
      age: json['age'] ?? 0,
      phase: json['phase'] ?? '',
      timeToHarvest: json['timeto_harvest'] ?? 0,
      commodity: json['commodity'] ?? '',
      variety: json['variety'] ?? '',
    );
  }
}

class Device {
  final String devId;
  final String? devImg;

  Device({required this.devId, this.devImg});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(devId: json['dev_id'] ?? '', devImg: json['dev_img']);
  }
}

class TodoGroup {
  final String plantId;
  final List<Todo> todos;

  TodoGroup({required this.plantId, required this.todos});

  factory TodoGroup.fromJson(Map<String, dynamic> json) {
    return TodoGroup(
      plantId: json['plant_id'] ?? '',
      todos: (json['todos'] as List).map((e) => Todo.fromJson(e)).toList(),
    );
  }
}

class Todo {
  final String handTitle;
  final String todoDate;
  final String fertilizerType;

  Todo({
    required this.handTitle,
    required this.todoDate,
    required this.fertilizerType,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      handTitle: json['hand_title'] ?? '',
      todoDate: json['todo_date'] ?? '',
      fertilizerType: json['fertilizer_type'] ?? '',
    );
  }
}
