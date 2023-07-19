import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:altmop/ui/settings/settings_loading.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsState();
}

class SettingsState extends State<SettingsScreen> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;
  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  String dataString = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  final _inputPassword = TextEditingController();
  final _inputSSID = TextEditingController();
  final _wellName = TextEditingController();
  final _tankLength = TextEditingController();
  final _tankWidth = TextEditingController();
  final _tankHeight = TextEditingController();
  final _inputAPI = TextEditingController();
  bool _isHidePassword = true;
  bool _isAdvShow = false;

  bool isValid = true;
  final _formKey = GlobalKey<FormState>();

  void toggleHidePassword() {
    setState(() {
      _isHidePassword = !_isHidePassword;
    });
  }

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.requestEnable();
    debugPrint("initstate");
    _startDiscovery();
  }

  @override
  void dispose() {
    _sendMessage(dataString);

    _inputPassword.dispose();
    _streamSubscription?.cancel();
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  void _startDiscovery() {
    debugPrint("start discovery");
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
        debugPrint(r.device.name);
        if (r.device.name == "ALTMOP") {
          try {
            bondAndConnect(r.device);
          } catch (ex) {
            // debugPrint(ex);
          }
        }
      });
    });
  }

  void bondAndConnect(BluetoothDevice device) async {
    bool bonded = false;
    if (device.isBonded) {
      debugPrint('${device.name} has bonded');
    } else {
      debugPrint('Bonding with ${device.name}...');
      bonded = (await FlutterBluetoothSerial.instance
          .bondDeviceAtAddress(device.address))!;
      debugPrint(
          'Bonding with ${device.name} has ${bonded ? 'succed' : 'failed'}.');
    }

    BluetoothConnection.toAddress(device.address).then((_connection) {
      debugPrint('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      _sendMessage('a');

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          debugPrint('Disconnecting locally!');
        } else {
          debugPrint('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      debugPrint('Cannot connect, exception occured');
      debugPrint(error);
    });
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    dataString = utf8.decode(buffer); //String.fromCharCodes(buffer);
    List<String> settings = dataString.split(',');
    _inputSSID.text = settings[0];
    _inputPassword.text = settings[1];
    _wellName.text = settings[2];
    _tankLength.text = settings[3];
    _tankWidth.text = settings[4];
    _tankHeight.text = settings[5];
    _inputAPI.text = settings[6];
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output
            .add(Uint8List.fromList(utf8.encode(text + ",end\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Settings"),
        centerTitle: true,
      ),
      floatingActionButton: !isConnected
          ? null
          : SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                label: const Text('Save Settings'),
                icon: const Icon(Icons.save_rounded),
                onPressed: !isValid
                    ? null
                    : () {
                        String message = _inputSSID.text +
                            ',' +
                            _inputPassword.text +
                            ',' +
                            _wellName.text +
                            ',' +
                            _tankLength.text +
                            ',' +
                            _tankWidth.text +
                            ',' +
                            _tankHeight.text +
                            ',' +
                            _inputAPI.text;
                        _sendMessage(message);
                        Navigator.of(context).pop();
                      },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
      body: !isConnected
          ? const SettingsLoading()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'WiFi Connection',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              enableSuggestions: true,
                              autocorrect: false,
                              controller: _inputSSID,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                labelText: 'Network SSID',
                                hintText: 'Enter Network Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Network SSID cannot be empty';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: _isHidePassword ? true : false,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _inputPassword,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                labelText: 'Password',
                                hintText: 'Enter Network Password',
                                suffixIcon: IconButton(
                                  icon: _isHidePassword
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  onPressed: () => toggleHidePassword(),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Network password cannot be empty';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Well and Tank Properties',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _wellName,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                labelText: 'Well Name',
                                hintText: 'Enter Well Name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Well name cannot be empty';
                                } else if (value.contains('_')) {
                                  return '"_" not allowed, use "-" instead';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _tankLength,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                labelText: 'Length',
                                hintText: 'in centimeters',
                                suffixText: 'cm',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Length cannot be empty';
                                } else if (int.parse(value) < 50) {
                                  return 'Minimum length 50 cm';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _tankWidth,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                labelText: 'Width',
                                hintText: 'in centimeters',
                                suffixText: 'cm',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Width cannot be empty';
                                } else if (int.parse(value) < 50) {
                                  return 'Minimum width 50 cm';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _tankHeight,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                labelText: 'Height',
                                hintText: 'in centimeters',
                                suffixText: 'cm',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Height cannot be empty';
                                } else if (int.parse(value) > 350) {
                                  return 'Maximum height 350 cm';
                                } else if (int.parse(value) < 50) {
                                  return 'Minimum height 50 cm';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  isValid = _formKey.currentState!.validate();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      InkWell(
                        // When the user taps the button, show a snackbar.
                        onTap: () => setState(() {
                          _isAdvShow = !_isAdvShow;
                        }),
                        child: Row(
                          children: [
                            Text(_isAdvShow
                                ? 'Hide Advance Setting'
                                : 'Show Advance Setting'),
                            Icon(
                              _isAdvShow
                                  ? Icons.arrow_drop_down_rounded
                                  : Icons.arrow_drop_up_rounded,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                      Visibility(
                        visible: _isAdvShow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'Server API',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _inputAPI,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.3),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      labelText: 'API Code',
                                      hintText: 'Input a right API Code',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'API code cannot be empty';
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        isValid =
                                            _formKey.currentState!.validate();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 70),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
