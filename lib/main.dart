import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Sign Apk Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _compareVersion=false;
  String _directory = '';
  FocusNode _directoryNode = FocusNode();
  final _directoryController = TextEditingController();
  final _directoryJiaGuController = TextEditingController();
  final _directorySignedApkOutputController = TextEditingController();
  final _directoryAppKeyController = TextEditingController();
  final _appKeyAliasController = TextEditingController();
  final _appKeyPasswordController = TextEditingController();
  final _directoryDestinationController = TextEditingController();
  List<Map<String, String>> _apkInfoToSigned = []; //需要加固的apk路径
  String _currentApkStatus = '请填完整相关进行后再进行一键签名';

  final _directoryOldController = TextEditingController();
  final _directoryNewController = TextEditingController();
  String _versionInfo='';
  String _versionTip='';
  bool showResult=false;
  bool showFullInfo=false;
  String oldFullInfo='';
  String newFullInfo='';

  void _swapFunction() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _compareVersion=!_compareVersion;
    });
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(_compareVersion ? 'Compare Version Info' : widget.title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _compareVersion ? _buildCompareWidget() : _buildSignWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _swapFunction,
        tooltip: 'Swap',
        child: const Icon(Icons.swap_horiz),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Column _buildSignWidget() {
    return Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildRow(
              controller: _directoryController,
              hindText: '选择Android SDK platform 目录',
              onButtonClick: () async {
                String? dir = await pickerDirectory();
                var temp = processPickedPathOrDir(dir);
                setState(() {
                  _directoryController.text = temp;
                });
              },
              onChanged: (value) {
                setState(() {
                  _directoryController.text = value;
                });
                _refreshCursor(_directoryController);
              },
              onDragDone: (files) {
                setState(() {
                  _directoryController.text = files.first.path;
                });
              }),
          SizedBox(
            height: 10,
          ),
          buildRow(
              controller: _directoryJiaGuController,
              hindText: '选择加固后需要签名的apk文件',
              onButtonClick: () async {
                FilePickerResult? result = await FilePicker.platform
                    .pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: ['apk']);
                debugPrint("result=$result");
                if (result != null) {
                  // List<File> files = result.paths.map((path) => File(path!)).toList();
                  List<PlatformFile> files = result.files;
                  _apkInfoToSigned.clear();
                  for (PlatformFile file in files) {
                    debugPrint('hello');
                    var temp = processPickedPathOrDir(file.path);
                    if (file.path != null) {
                      Map<String, String> map = {};
                      map['path'] = file.path!;
                      map['name'] = file.name!;
                      _apkInfoToSigned.add(map);
                    }
                    setState(() {
                      if (_directoryJiaGuController.text.trim().isNotEmpty) {
                        _directoryJiaGuController.text += '\n';
                        _directoryJiaGuController.text += temp;
                      } else {
                        _directoryJiaGuController.text = temp;
                      }
                    });
                  }
                }
                // String? dir = await pickerDirectory();
                // if (dir != null) {
                //   setState(() {
                //     _directoryJiaGuController.text = dir;
                //   });
                // }
              },
              onChanged: (value) {
                if (value.contains('\n')) {
                  print("value");
                  List<String> temp = value.split('\n');
                  _apkInfoToSigned.clear();
                  for (var path in temp) {
                    Map<String, String> map = {};
                    map['path'] = path;
                    map['name'] = path.substring(path.lastIndexOf("\/") + 1);
                    _apkInfoToSigned.add(map);
                  }
                }
                setState(() {
                  _directoryJiaGuController.text = value;
                });
                _refreshCursor(_directoryJiaGuController);
              },
              onDragDone: (files) {
                for (var file in files) {
                  if (file.name.endsWith('.apk')) {
                    if (file.path != null) {
                      Map<String, String> map = {};
                      map['path'] = file.path;
                      map['name'] = file.name;
                      _apkInfoToSigned.add(map);
                    }
                    setState(() {
                      if (_directoryJiaGuController.text.trim().isNotEmpty) {
                        _directoryJiaGuController.text += '\n';
                        _directoryJiaGuController.text += file.path;
                      } else {
                        _directoryJiaGuController.text = file.path;
                      }
                    });
                  }
                }
              }),
          SizedBox(
            height: 10,
          ),
          buildRow(
              controller: _directorySignedApkOutputController,
              hindText: '选择签名后的输出目录',
              onButtonClick: () async {
                String? dir = await pickerDirectory();
                String temp = processPickedPathOrDir(dir);
                setState(() {
                  _directorySignedApkOutputController.text = temp;
                });
              },
              onChanged: (value) {
                setState(() {
                  _directorySignedApkOutputController.text = value;
                });
                _refreshCursor(_directorySignedApkOutputController);
              },
              onDragDone: (files) {
                setState(() {
                  _directorySignedApkOutputController.text = files.first.path;
                });
              }),
          SizedBox(
            height: 10,
          ),
          buildRow(
              controller: _directoryAppKeyController,
              hindText: '选择App签名文件',
              onButtonClick: () async {
                FilePickerResult? result = await FilePicker.platform
                    .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jks', 'keystore']);
                if (result != null) {
                  PlatformFile file = result.files.first;
                  var temp = processPickedPathOrDir(file.path);
                  setState(() {
                    _directoryAppKeyController.text = temp;
                  });
                }else{
debugPrint('为空');
                }
                // String? dir = await pickerDirectory();
                // String temp = processPickedPathOrDir(dir);
                // setState(() {
                //   _directoryAppKeyController.text = temp;
                // });
              },
              onChanged: (value) {
                setState(() {
                  _directoryAppKeyController.text = value;
                });
                _refreshCursor(_directoryAppKeyController);
              },
              onDragDone: (files) {
                if (files.first.name.endsWith('.jks') ||
                    files.first.name.endsWith('.keystore')) {
                  setState(() {
                    _directoryAppKeyController.text = files.first.path;
                  });
                }
              }),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                obscureText: true,
                controller: _appKeyAliasController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x00FF0000)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  hintText: '输入App Key的alias',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x00000000)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
                onChanged: (value) {
                  setState(() {
                    _appKeyAliasController.text = value;
                  });
                  _refreshCursor(_appKeyAliasController);
                },
              )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextField(
                controller: _appKeyPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x00FF0000)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  hintText: '输入App Key的密码',
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0x00000000)),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
                onChanged: (value) {
                  setState(() {
                    _appKeyPasswordController.text = value;
                  });
                  _refreshCursor(_appKeyPasswordController);
                },
              )),
            ],
          ),
          // buildRow(
          //     hindText: '输入App Key的alias',
          //     onButtonClick: () async {
          //       String? dir = await pickerDirectory();
          //       if (dir != null) {
          //         setState(() {
          //           _appKeyAliasController.text = dir;
          //         });
          //       }
          //     }),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                _currentApkStatus,
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () async {
                for (var info in _apkInfoToSigned) {
                  //根据选择的要签名的文件一个一个进行签名
                  setState(() {
                    _currentApkStatus = '正在对 ${info['name']} 进行签名';
                  });
                  await processSignApk(info);
                }
                // process.exitCode.then((exitCode) {
                //   print('Exit code: $exitCode');
                // });
              },
              child: Text('一键签名')),
          SizedBox(
            height: 30,
          ),
          buildRow(
              controller: _directoryDestinationController,
              hindText: '请输入你要前往的目录',
              buttonText: '前往',
              onButtonClick: () async {
                String path = _directoryDestinationController.text.trim();
                if (await Directory(path).exists()) {
                  await Process.run('open', [path]);
                } else {
                  print('Directory does not exist: $path');
                }
              },
              onChanged: (value) {
                setState(() {
                  _directoryDestinationController.text = value;
                });
                _refreshCursor(_directoryDestinationController);
              },
              onDragDone: (files) {
                setState(() {
                  _directoryDestinationController.text = files.first.path;
                });
              }),
        ],
      );
  }

  Column _buildCompareWidget() {
    return Column(
      children: [
        buildRow(
            controller: _directoryController,
            hindText: '选择Android SDK platform 目录',
            onButtonClick: () async {
              String? dir = await pickerDirectory();
              var temp = processPickedPathOrDir(dir);
              setState(() {
                _directoryController.text = temp;
              });
            },
            onChanged: (value) {
              setState(() {
                _directoryController.text = value;
              });
              _refreshCursor(_directoryController);
            },
            onDragDone: (files) {
              setState(() {
                _directoryController.text = files.first.path;
              });
            }),
        SizedBox(
          height: 10,
        ),
        buildRow(
            controller: _directoryOldController,
            hindText: '选择旧版本的apk文件',
            onButtonClick: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['apk']);
              debugPrint("result=$result");
              if (result != null) {
                // List<File> files = result.paths.map((path) => File(path!)).toList();
                List<PlatformFile> files = result.files;
                for (PlatformFile file in files) {
                  debugPrint('hello');
                  var temp = processPickedPathOrDir(file.path);
                  setState(() {
                    // if (_directoryOldController.text.trim().isNotEmpty) {
                    //   _directoryOldController.text += '\n';
                    //   _directoryOldController.text += temp;
                    // } else {
                    _directoryOldController.text = temp;
                    // }
                  });
                }
              }
            },
            onChanged: (value) {
              setState(() {
                _directoryOldController.text = value;
              });
              _refreshCursor(_directoryOldController);
            },
            onDragDone: (files) {
              for (var file in files) {
                if (file.name.endsWith('.apk')) {
                  setState(() {
                    // if (_directoryOldController.text.trim().isNotEmpty) {
                    //   _directoryOldController.text += '\n';
                    //   _directoryOldController.text += file.path;
                    // } else {
                    _directoryOldController.text = file.path;
                    // }
                  });
                }
              }
            }),
        SizedBox(
          height: 10,
        ),
        buildRow(
            controller: _directoryNewController,
            hindText: '选择新版本的apk文件',
            onButtonClick: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['apk']);
              debugPrint("result=$result");
              if (result != null) {
                // List<File> files = result.paths.map((path) => File(path!)).toList();
                List<PlatformFile> files = result.files;

                for (PlatformFile file in files) {
                  debugPrint('hello');
                  var temp = processPickedPathOrDir(file.path);
                  setState(() {
                    // if (_directoryNewController.text.trim().isNotEmpty) {
                    //   _directoryNewController.text += '\n';
                    //   _directoryNewController.text += temp;
                    // } else {
                    _directoryNewController.text = temp;
                    // }
                  });
                }
              }
            },
            onChanged: (value) {
              setState(() {
                _directoryNewController.text = value;
              });
              _refreshCursor(_directoryNewController);
            },
            onDragDone: (files) {
              for (var file in files) {
                if (file.name.endsWith('.apk')) {
                  setState(() {
                    // if (_directoryNewController.text.trim().isNotEmpty) {
                    //   _directoryNewController.text += '\n';
                    //   _directoryNewController.text += file.path;
                    // } else {
                    _directoryNewController.text = file.path;
                    // }
                  });
                }
              }
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              _versionTip,
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: () async {
                  showFullInfo = false;
                  if (_directoryOldController.text.isEmpty ||
                      _directoryNewController.text.isEmpty) {
                    setState(() {
                      _versionTip = 'apk路径不能为空';
                      showResult = false;
                    });
                    return;
                  }
                  final oldInfo =
                      await processApkInfo(_directoryOldController.text);
                  final newInfo =
                      await processApkInfo(_directoryNewController.text);
                  setState(() {
                    _versionTip = '';
                    _versionInfo =
                        '老版本：versionName=${oldInfo['versionName']}\tversionCode=${oldInfo['versionCode']}\n'
                        '新版本：versionName=${newInfo['versionName']}\tversionCode=${newInfo['versionCode']}\n'
                        'versionName${oldInfo['versionName']!.compareTo(newInfo['versionName']!) != 0 ? '不相同' : '相同'}\n'
                        'versionCode${oldInfo['versionCode']!.compareTo(newInfo['versionCode']!) != 0 ? '不相同' : '相同'}';
                    showResult = true;
                  });

                  // process.exitCode.then((exitCode) {
                  //   print('Exit code: $exitCode');
                  // });
                },
                child: Text('对比版本信息')),
            ElevatedButton(
                onPressed: () async {
                  if (_directoryOldController.text.isEmpty ||
                      _directoryNewController.text.isEmpty) {
                    setState(() {
                      _versionTip = 'apk路径不能为空';
                      showResult = false;
                      showFullInfo = true;
                    });
                    return;
                  }
                  final oldInfo =
                      await processAllApkInfo(_directoryOldController.text);
                  final newInfo =
                      await processAllApkInfo(_directoryNewController.text);
                  setState(() {
                    showResult = false;
                    showFullInfo = true;
                    oldFullInfo = oldInfo;
                    newFullInfo = newInfo;
                  });
                },
                child: Text('显示全部信息'))
          ],
        ),
        SizedBox(
          height: 10,
        ),
        showFullInfo
            ? Expanded(
                child: Row(
                children: [
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(oldFullInfo),
                    ),
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5)),
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(newFullInfo),
                    ),
                  ))
                ],
              ))
            : showResult
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '对比结果如下\n\n$_versionInfo',
                        textAlign: TextAlign.start,
                      )
                    ],
                  )
                : const SizedBox(),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Future<void> processSignApk(Map<String, String> apkInfo) async {
    String commandZipAlign = '${_directoryController.text.trim()}/zipalign';
    String inputApkPath = apkInfo['path']!;
    String inputApkName = apkInfo['name']!;
    String zipAlignOutPakName =
        inputApkName.substring(0, inputApkName.indexOf('.apk'));
    //最终签名后的apk路径，并对生成的apk重命名
    String signedApkOutputPath =
        '${_directorySignedApkOutputController.text.trim()}/signed/${zipAlignOutPakName}_signed.apk';
    //对齐的apk路径，并对生成的apk重命名
    String zipAlignOutputApkPath =
        '${_directorySignedApkOutputController.text.trim()}/temp/${zipAlignOutPakName}_zipAlign.apk';
    var fileSignedApk = File(signedApkOutputPath);
    if (await fileSignedApk.exists()) {
      await fileSignedApk.delete();
    }
    var fileZipAlignApk = File(zipAlignOutputApkPath);
    if (await fileZipAlignApk.exists()) {
      await fileZipAlignApk.delete();
    }

    final argsZipAlign = ['-v', '-p', '4', inputApkPath, zipAlignOutputApkPath];
    final process = await Process.start(commandZipAlign, argsZipAlign);
    // String inputApkPath =
    //     '/Users/kevinjing/Library/Containers/com.360jiaguzhushou.jgb/Data/Document/jiagu.bundle/Contents/Resources/jiagu/output/jingpengchn@163.com/app-qbPro-armeabi-v7a-release_279_jiagu.apk';
    // String inputApkPath='/Users/kevinjing/Downloads/aaaaaa/test.apk';
    // String zipAlignApkPath = '';
    // final process = await Process.start(
    //     '/Users/kevinjing/Library/Android/sdk/build-tools/33.0.0/zipalign',
    //     ['-v', '-p', '4', inputApkPath, outputApkPath]);
    // final process = await Process.start('mkdir', ['/Users/kevinjing/Downloads/你好']);

    process.stdout.transform(utf8.decoder).listen((data) {
      print('stdout: $data');
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      print('stderr: $data');
    });
    var code = await process.exitCode;
    if (code == 0) {
      //对齐后执行签名
      String commandApkSign = '${_directoryController.text.trim()}/apksigner';
      final args = [
        'sign',
        '--ks',
        _directoryAppKeyController.text.trim(),
        '--ks-key-alias',
        _appKeyAliasController.text.trim(),
        '--ks-pass',
        'pass:${_appKeyPasswordController.text.trim()}',
        '--v2-signing-enabled',
        'true',
        '--out',
        signedApkOutputPath, //签名后的apk
        zipAlignOutputApkPath //要签名的apk
      ];
      ProcessResult result = await Process.run(commandApkSign, args);
      print('result=${result.stdout} \n ${result.exitCode},\n${result.stderr}');
      if (result.exitCode == 0) {
        setState(() {
          _currentApkStatus = '${inputApkName}签名完成';
        });
      } else {
        setState(() {
          _currentApkStatus = '${inputApkName}签名失败';
        });
      }
    }

    // process.exitCode.then((exitCode) {
    //   print('Exit code: $exitCode');
    // });
  }

  Future<String?> pickerDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  String processPickedPathOrDir(String? pathOrDir) {
    print("pathOrDir=${pathOrDir}");
    var temp = '';
    if (pathOrDir != null) {
      int pos = pathOrDir.indexOf('/Users');
      if (pos >= 0) {
        temp = pathOrDir.substring(pos);
      }
    }
    return temp;
  }

  Future<String> processAllApkInfo(String apkPath) async{
    var executable = '${_directoryController.text.trim()}/aapt';
    var args = ['dump', 'badging', apkPath];
    final ProcessResult result = await Process.run(executable, args);
    print('result=${result.stdout} \n ${result.exitCode},\n${result.stderr}');
    // 解析输出
    final stdout = result.stdout as String;
    return stdout;
  }
  Future<Map<String,String>> processApkInfo(String apkPath) async{
    var executable = '${_directoryController.text.trim()}/aapt';
    var args = ['dump', 'badging', apkPath];
    var map=<String,String>{};
    final ProcessResult result = await Process.run(executable, args);
    print('result=${result.stdout} \n ${result.exitCode},\n${result.stderr}');
    // 解析输出
    final stdout = result.stdout as String;
    final versionNameRegExp = RegExp(r"versionName='([^']+)'");
    final versionCodeRegExp = RegExp(r"versionCode='([^']+)'");
    final versionNameMatch = versionNameRegExp.firstMatch(stdout);
    final versionCodeMatch = versionCodeRegExp.firstMatch(stdout);

    if (versionNameMatch != null && versionCodeMatch != null) {
      String versionName = versionNameMatch.group(1)!;
      String versionCode = versionCodeMatch.group(1)!;
      map['versionName']=versionName;
      map['versionCode']=versionCode;
    } else {
      throw Exception('Failed to extract version information from APK');
    }
    return map;
  }

  _refreshCursor(TextEditingController controller) {
    int length = controller.text.length;
    controller.selection =
        TextSelection(baseOffset: length, extentOffset: length);
  }

  Row buildRow(
      {TextEditingController? controller,
      FocusNode? focusNode,
      String hindText = '',
      String buttonText = '浏览',
      Function? onButtonClick,
      Function(String value)? onChanged,
      Function(List<XFile> files)? onDragDone}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DropTarget(
            onDragDone: (detail) {
              List<XFile> files = detail.files;
              if (files.isNotEmpty) {
                onDragDone?.call(files);
              }
            },
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              maxLines: null,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00FF0000)),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                hintText: hindText,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x00000000)),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
              ),
              onChanged: (value) {
                onChanged?.call(value);
              },
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          child: ElevatedButton(
              onPressed: () {
                onButtonClick?.call();
              },
              child: Text(buttonText)),
        )
      ],
    );
  }
}
