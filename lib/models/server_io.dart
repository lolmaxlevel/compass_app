class Request {
  final String type;
  final String time;

  Request(
      {
        this.type = "non-type",
        this.time = "",
      });

  Request.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        time = json['time'];

  Map<String, dynamic> toJson() => {
    'type':       'non-request',
    'time':       DateTime.now().microsecondsSinceEpoch.toString(),
  };
}

class LocationRequest extends Request {
  final String type;
  final String id;
  final String latitude;
  final String longitude;
  final String altitude;
  final String accuracy;
  final String bearing;
  final String speed;
  final String time;

  LocationRequest(this.type,this.id, this.latitude, this.longitude,
        this.altitude, this.accuracy, this.bearing, this.speed, this.time);

  LocationRequest.fromJson(Map<String, dynamic> json)
      :
        type = json['type'],
        id = json['id'],
        latitude = json['lat'],
        longitude = json['long'],
        altitude = json['alt'],
        accuracy = json['accuracy'],
        bearing = json['bearing'],
        speed = json['speed'],
        time = json['time'];

  @override
  Map<String, dynamic> toJson() => {
    'type':       "location",
    'id':         id,
    'lat':        latitude,
    'long':       longitude,
    'alt':        altitude,
    'accuracy':   accuracy,
    'bearing':    bearing,
    'speed':      speed,
    'time':       DateTime.now().microsecondsSinceEpoch.toString(),
  };
}


class HandShakeRequest extends Request{
  final String id;

  HandShakeRequest(this.id);


  @override
  Map<String, dynamic> toJson() => {
    'type':       "Handshake",
    'id':         id,
  };
}

class CompassRequest extends Request{
  final String type;
  final String id;
  final String partnerId;
  final String status;

  CompassRequest(
  {
    this.type = "compass",
    required this.id,
    required this.partnerId,
    required this.status,
  });

  CompassRequest.fromJson(Map<String, dynamic> json)
      :
        type = json['type'],
        id = json['id'],
        partnerId = json['partnerId'],
        status = json['status'];

  @override
  Map<String, dynamic> toJson() => {
    'type':       "compass",
    'id':         id,
    'partnerId':  partnerId,
    'status':     status,
    'time':       DateTime.now().microsecondsSinceEpoch.toString(),
  };
}