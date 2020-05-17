import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:exif/exif.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Authenticate',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List selectedImage = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatform();
  }

  initPlatform() async {
    if (await Permission.storage.isUndetermined) {
      Permission.storage.request();
    } else {
      print('permission');
    }
  }

  parseDegree(degreeList){
    var latitudeDegree = degreeList[0].numerator;
    var latitudeMin = degreeList[1].numerator / 60;
    var latitudeSec = (degreeList[2].numerator / degreeList[2].denominator) / 3600;
    return latitudeDegree + latitudeMin + latitudeSec;
  }

  Future<String> exifFilter(path) async {
    Map<String, IfdTag> data = await readExifFromBytes(await new File(path).readAsBytes());
    if(data == null || data.isEmpty) {
      return null;
    }

    if(!data.containsKey('GPS GPSLatitude') || !data.containsKey('GPS GPSLongitude')){
      return null;
    }

    var latitudeList = data['GPS GPSLatitude'].values;
    var longitudeList = data['GPS GPSLongitude'].values;

    var latitude = parseDegree(latitudeList);
    var longitude = parseDegree(longitudeList);

    var naverGeocodeBaseUrl = 'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';
    var queryString = 'request=coordsToaddr&coords=${longitude},${latitude}&sourcecrs=epsg:4326&output=json&orders=legalcode';
    var url = '$naverGeocodeBaseUrl?$queryString';

    var response = await http.get(url, headers: {
      'X-NCP-APIGW-API-KEY-ID': await DotEnv().env['NAVER_CLIENT_ID'],
      'X-NCP-APIGW-API-KEY': await DotEnv().env['NAVER_CLIENT_SECRET'],
    });

    Map<String, dynamic> responseBody = jsonDecode(response.body);
  }

  allImages() async {
    var path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    var images = Directory(path).listSync(recursive: true, followLinks: false);
    var futures = images.map((image) => exifFilter(image.path));
    var test = await Future.wait(futures);
    print(test);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(child: Text('on click'), onPressed: allImages),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: selectedImage.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(selectedImage[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
