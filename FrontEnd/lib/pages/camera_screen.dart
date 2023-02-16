import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_4/pages/sencond_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  @override
  CameraController? controller;
  bool _isCameraInitialized = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      print("Picture already taken");
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      final directory = (await getApplicationDocumentsDirectory()).path;
      // print("Directory $directory");
      // print("picture taken successfully");
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        print(_isRecordingInProgress);
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<http.Response> uploadFile(File file,
      [String contentType = 'image/jpeg']) async {
    // Get the file as a list of bytes
    List<int> fileBytes = file.readAsBytesSync();

    // Define the endpoint URL
    String url = "https://your-server.com/upload";

    // Define the headers for the request
    Map<String, String> headers = {
      'Content-Type': contentType,
      'Content-Length': fileBytes.length.toString(),
    };

    // Make the HTTP POST request
    return http.post(Uri(path: url), headers: headers, body: fileBytes);
  }

  @override
  void initState() {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIOverlays([]);
    int idx = 0;
    // cameras.length();
    onNewCameraSelected(cameras[idx]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    // videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;

  var _videoFile;
  @override
  Widget build(BuildContext context) {
    // var _isRecordingInProgress;
    return Material(
      child: Scaffold(
        body: _isCameraInitialized
            ?
            // aspectRatio: 1 / controller!.value.aspectRatio,
            controller!.buildPreview()
            : Container(),
        persistentFooterButtons: [
          OverflowBar(
            children: [
              InkWell(
                onTap: !_isVideoCameraSelected
                    ? () async {
                        XFile? rawImage = await takePicture();
                        // print("rawImage");
                        File imageFile = File(rawImage!.path); //Image
                        // print("imageFile");
                        int currentUnix = DateTime.now().millisecondsSinceEpoch;
                        // print("$currentUnix");
                        final directory =
                            await getApplicationDocumentsDirectory();
                        // print("$directory");
                        String fileFormat = imageFile.path.split('.').last;
                        // print("$fileFormat");
                        await imageFile.copy(
                          '${directory.path}/$currentUnix.$fileFormat',
                        );
                        var response =
                            await uploadFile(imageFile, 'image/jpeg');
                        if (response.statusCode == 200) {
                          // Handle successful response
                        } else {
                          // Handle error
                        }
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SecondPage()),
                        );
                      }
                    : () async {
                        if (_isRecordingInProgress) {
                          XFile? rawVideo = await stopVideoRecording();
                          File videoFile = File(rawVideo!.path); //VideoFile
                          // print("Video file $videoFile");
                          // print("Video file type $videoFile.rumtimetype()");

                          int currentUnix =
                              DateTime.now().millisecondsSinceEpoch;

                          final directory =
                              await getApplicationDocumentsDirectory();
                          String fileFormat = videoFile.path.split('.').last;

                          _videoFile = await videoFile.copy(
                            '${directory.path}/$currentUnix.$fileFormat',
                          );
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SecondPage()),
                          );
                        } else {
                          await startVideoRecording();
                        }
                      },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Colors.black45,
                          size: 80,
                        ),
                        Icon(
                          Icons.circle,
                          color: _isVideoCameraSelected
                              ? Colors.red
                              : Colors.white,
                          size: 65,
                        ),
                        _isVideoCameraSelected && _isRecordingInProgress
                            ? const Icon(
                                Icons.stop_rounded,
                                color: Colors.white,
                                size: 32,
                              )
                            : Container(),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 4.0,
                            ),
                            child: TextButton(
                              onPressed: _isRecordingInProgress
                                  ? null
                                  : () {
                                      if (_isVideoCameraSelected) {
                                        setState(() {
                                          _isVideoCameraSelected = false;
                                        });
                                      }
                                    },
                              style: TextButton.styleFrom(
                                primary: _isVideoCameraSelected
                                    ? Colors.black54
                                    : Colors.black,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white30
                                    : Colors.white,
                              ),
                              child: Text('IMAGE'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                // left: 4.0, right: 8.0
                                ),
                            child: TextButton(
                              onPressed: () {
                                if (!_isVideoCameraSelected) {
                                  setState(() {
                                    _isVideoCameraSelected = true;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                primary: _isVideoCameraSelected
                                    ? Colors.black
                                    : Colors.black54,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                              child: Text('VIDEO'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
