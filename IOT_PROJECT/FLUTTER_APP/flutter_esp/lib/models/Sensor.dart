// ignore_for_file: file_names

class Sensor {
  final List<double> temp;
  final List<double> volt;
  int data;

  Sensor({required this.temp, required this.volt, required this.data});

  factory Sensor.fromJson(Map<String, dynamic> parsedJson) {
    var tempFromJson = parsedJson['temp'];
    //print(streetsFromJson.runtimeType);
    // List<String> streetsList = new List<String>.from(streetsFromJson);
    List<double> templist = tempFromJson.cast<double>();
    int data = parsedJson['data'];
    var voltFromJson = parsedJson['volt'];
    //print(streetsFromJson.runtimeType);
    // List<String> streetsList = new List<String>.from(streetsFromJson);
    List<double> voltlist = voltFromJson.cast<double>();

    return Sensor(temp: templist, volt: voltlist, data: data);
  }
}
