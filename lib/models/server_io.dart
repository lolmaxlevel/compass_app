class Request {
  final String id;
  final String partnerId;
  final String latitude;
  final String longitude;
  final String altitude;
  final String accuracy;
  final String bearing;
  final String speed;
  final String time;

  Request(this.id, this.partnerId, this.latitude, this.longitude,
        this.altitude, this.accuracy, this.bearing, this.speed, this.time);

  Request.fromJson(Map<String, dynamic> json)
  : id = json['id'],
    partnerId = json['partner_id'],
    latitude = json['lat'],
    longitude = json['long'],
    altitude = json['alt'],
    accuracy = json['accuracy'],
    bearing = json['bearing'],
    speed = json['speed'],
    time = json['time'];

  Map<String, dynamic> toJson() => {
    'id':         id,
    'partner_id': partnerId,
    'lat':        latitude,
    'long':       longitude,
    'alt':        altitude,
    'accuracy':   accuracy,
    'bearing':    bearing,
    'speed':      speed,
    'time':       time,
  };
}