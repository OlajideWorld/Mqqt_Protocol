import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final brokerAddress = 'tcp://7.tcp.eu.ngrok.io:13952';
  final mqttClient =
      MqttServerClient.withPort("2.tcp.eu.ngrok.io", 'Olajide',18363);

  int _counter = 0;
  final TextEditingController _message = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectToBroker();
  }

  void subscribeToTopic() {
    const topicToDevice = 'devices/solar_charge_controller';

    final qosLevel = MqttQos.atLeastOnce;

    mqttClient.subscribe(topicToDevice, qosLevel);
  }

  void onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    messages.forEach((message) {
      final MqttPublishMessage payload = message.payload as MqttPublishMessage;
      final data =
          MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      // Handle the incoming message here based on the topic and data.
      print(
          'Received message: ${payload.variableHeader!.topicName}, data: $data');
    });
  }

  Future<void> connectToBroker() async {
    try {
      await mqttClient.connect();
      debugPrint('Connected to MQTT broker.');
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
    }
  }

  Future<void> publishToDevices(String message) async {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    final topicFromApp = 'app/to_devices';
    final payload = builder.payload;

    if (payload != null) {
      mqttClient.publishMessage(topicFromApp, MqttQos.exactlyOnce, payload);
    } else {
      print('Payload is null. Message not sent.');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: TextFormField(
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  cursorColor: Colors.white,
                  controller: _message,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_clock_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700)),
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.7)),
                      hintText: 'Enter message'),
                  validator: (value) {
                    // You can add more username validation if needed
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => publishToDevices(_message.text.trim()),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(color: Colors.blue),
                  child: const Center(
                    child: Text(
                      "Send Message",
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
