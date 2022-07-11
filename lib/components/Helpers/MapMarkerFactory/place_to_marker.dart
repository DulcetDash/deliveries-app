import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:orniss/components/Helpers/MapMarkerFactory/custom_marker.dart';
import 'package:orniss/components/Helpers/MapMarkerFactory/place.dart';

Future<BitmapDescriptor> placeToMarker(String title, int? duration) async {
  final recoder = ui.PictureRecorder();
  final canvas = ui.Canvas(recoder);
  const size = ui.Size(380, 100);

  final customMarker = MyCustomMarker(
    label: title,
    duration: duration,
  );
  customMarker.paint(canvas, size);
  final picture = recoder.endRecording();
  final image = await picture.toImage(
    size.width.toInt(),
    size.height.toInt(),
  );
  final byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  final bytes = byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}
