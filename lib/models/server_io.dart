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
  final String partnerId;
  final String latitude;
  final String longitude;
  final String altitude;
  final String accuracy;
  final String bearing;
  final String speed;
  final String time;

  LocationRequest(this.type,this.id, this.partnerId, this.latitude, this.longitude,
        this.altitude, this.accuracy, this.bearing, this.speed, this.time);

  LocationRequest.fromJson(Map<String, dynamic> json)
      :
        type = json['type'],
        id = json['id'],
        partnerId = json['partner_id'],
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
    'partner_id': partnerId,
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
  final String partnerId;

  HandShakeRequest(this.id, this.partnerId);


  Map<String, dynamic> toJson() => {
    'type':       "Handshake",
    'id':         id,
    'partner_id': partnerId,
  };
}