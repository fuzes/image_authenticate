import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:imageauthenticate/address_manager.dart';
import 'package:imageauthenticate/geodecode.dart';
import 'package:imageauthenticate/image.dart';
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
  List<ImageForAuthenticate> imagesForAuthenticate = new List();

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

  calculateDegree(degreeList) {
    var latitudeDegree = degreeList[0].numerator;
    var latitudeMin = degreeList[1].numerator / 60;
    var latitudeSec =
        (degreeList[2].numerator / degreeList[2].denominator) / 3600;
    return latitudeDegree + latitudeMin + latitudeSec;
  }

  reverseGeocoding(longitude, latitude) async {
    var naverGeocodeBaseUrl =
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';
    var queryString =
        'request=coordsToaddr&coords=${longitude},${latitude}&sourcecrs=epsg:4326&output=json&orders=legalcode';
    var url = '$naverGeocodeBaseUrl?$queryString';

    var response = await http.get(url, headers: {
      'X-NCP-APIGW-API-KEY-ID': await DotEnv().env['NAVER_CLIENT_ID'],
      'X-NCP-APIGW-API-KEY': await DotEnv().env['NAVER_CLIENT_SECRET'],
    });

    Map<String, dynamic> responseBody = jsonDecode(response.body);
    GeoDecodeResult geoDecodeResult = GeoDecodeResult.fromJson(responseBody);
    var cityName = geoDecodeResult.results[0].region.area1.name;
    var localName = geoDecodeResult.results[0].region.area2.name;
    return '$cityName $localName';
  }

  Future<String> exifFilter(String path) async {
    Map<String, IfdTag> data =
        await readExifFromBytes(await new File(path).readAsBytes());
    if (data == null || data.isEmpty) {
      return null;
    }

    if (!data.containsKey('GPS GPSLatitude') ||
        !data.containsKey('GPS GPSLongitude')) {
      return null;
    }

    var latitudeList = data['GPS GPSLatitude'].values;
    var longitudeList = data['GPS GPSLongitude'].values;

    var latitude = calculateDegree(latitudeList);
    var longitude = calculateDegree(longitudeList);

    var address = await reverseGeocoding(longitude, latitude);
    return address;
  }

  findAllImagePath(String rootPath) async {
    var path = await ExtStorage.getExternalStoragePublicDirectory(rootPath);
    var allImages =
        Directory(path).listSync(recursive: true, followLinks: false);
    var imagePaths = allImages
        .map((image) => image.path)
        .where((path) => path.endsWith('jpeg'))
        .toList();
    imagePaths.shuffle();
    return imagePaths;
  }

  pickImages() async {
    var allImages = await findAllImagePath(ExtStorage.DIRECTORY_DOWNLOADS);
    List<ImageForAuthenticate> images = new List();

    for (var i = 0; i < allImages.length; i++) {
      var address = await exifFilter(allImages[i]);
      if (images.length > 8) {
        break;
      }
      if (address != null) {
        images.add(ImageForAuthenticate(path: allImages[i], address: address));
      }
    }

    setState(() {
      imagesForAuthenticate = images;
    });

//    var futures = allImages.map((image) => exifFilterilter(image.path));
//    var test = await Future.wait(futures);
//    print(test);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    RaisedButton(child: Text('분석 시작'), onPressed: pickImages),
                    SizedBox(width: 10.0),
                    RaisedButton(
                      child: Text('인증'),
                      onPressed: () {
                        var isAllChecked = imagesForAuthenticate.every((element) => element.isChecked == true);
                        if(!isAllChecked){
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text('9개 모두 확인해주세요'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            }
                          );
                          return;
                        }
                        var isAuthenticated = imagesForAuthenticate.every((element) => element.isAuthenticated == true);
                        if(!isAuthenticated){
                          showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text('인증 실패'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              }
                          );
                          return;
                        }
                      },
                    )
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: imagesForAuthenticate.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: imagesForAuthenticate[index].isChecked ? Colors.red : Colors.white,
                        width: 5.0,
                      )
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String selectRatio;
                              AddressManager addressManager = new AddressManager();
                              var pickList = addressManager.makeSelectableList(imagesForAuthenticate[index].address);
                              return AlertDialog(
                                content: StatefulBuilder(
                                  builder: (BuildContext context, StateSetter setState){
                                    return Column(  // Then, the content of your dialog.
                                      mainAxisSize: MainAxisSize.min,
                                      children: List<Widget>.generate(pickList.length, (int index) {
                                        print(pickList[index]);
                                        return Row(
                                          children: <Widget>[
                                            Radio<String>(
                                              value: pickList[index],
                                              groupValue: selectRatio,
                                              onChanged: (String value) {
                                                // Whenever you need, call setState on your variable
                                                setState(() => selectRatio = value);
                                              },
                                            ),
                                            Text(pickList[index]),
                                          ],
                                        );
                                      }),
                                    );
                                  },
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      if(selectRatio == imagesForAuthenticate[index].address){
                                        imagesForAuthenticate[index].isAuthenticated = true;
                                      } else {
                                        imagesForAuthenticate[index].isAuthenticated = false;
                                      }
                                      setState(() {
                                        imagesForAuthenticate[index].isChecked = true;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK')
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('CANCEL'),
                                  ),
                                ],
                              );
                            });
                        print(imagesForAuthenticate[index]);
                      },
                      child: Image.file(File(imagesForAuthenticate[index].path)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
