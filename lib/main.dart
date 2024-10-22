import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AquariumApp());
}

class AquariumApp extends StatelessWidget {
  const AquariumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquarium Park',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  AquariumState createState() => AquariumState();
}

class AquariumState extends State<AquariumScreen> {
  List<Fish> fishList = [];
  Color colour = Colors.blue;
  double speed = 1.2;
  final int maximum = 11;
  List<Color> colors = [Colors.blue, Colors.green, Colors.red]; 

  
  void addFish() {
    if (fishList.length < maximum) {
      setState(() {
        fishList.add(Fish(color: colour, speed: speed));
      });
    }
  }

 
  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fishCount', fishList.length);
    await prefs.setDouble('fishSpeed', speed);
    await prefs.setInt('fishColor', colour.value);
  }


  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? fishCount = prefs.getInt('fishCount');
    double? fishSpeed = prefs.getDouble('fishSpeed');
    int? fishColor = prefs.getInt('fishColor');

    setState(() {
      fishList = List.generate(fishCount ?? 0, (_) => Fish(color: Color(fishColor ?? Colors.blue.value), speed: fishSpeed ?? 1.0));
      speed = fishSpeed ?? 1.0;
      Color loadedColor = Color(fishColor ?? Colors.blue.value);
      if (colors.contains(loadedColor)) {
        colour = loadedColor; 
      } else {
        colour = colors[0]; 
      }
      //colour = Color(fishColor ?? Colors.blue.value);

    });
  }

  @override
  void initState() {
  super.initState();
  colour = colors[0]; 
  load();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Aquarium Park'),
    ),
    body: Column(
      children: [
        Container(
          width: 300,
          height: 300,
          color: Colors.blue[100],
          child: Stack(
            children: fishList.map((fish) => fishWidget(fish)).toList(),
          ),
        ),
        Slider(
          value: speed,
          min: 0.5,
          max: 3.0,
          label: 'Speed: ${speed.toStringAsFixed(1)}',
          onChanged: (value) {
            setState(() {
              speed = value;
            });
          },
        ),
        DropdownButton<Color>(
          hint: const Text("Select a colour"),
          value: colour,
          items: colors.map((Color color) {
            return DropdownMenuItem<Color>(
              value: color,
              child: Container(
                width: 24,
                height: 24,
                color: color,
              ),
            );
          }).toList(),
          onChanged: (color) {
            setState(() {
              if (color != null) {
                colour = color;
              }
            });
          },
        ),
        ElevatedButton(
          onPressed: addFish,
          child: const Text('Add Fish'),
        ),
        ElevatedButton(
          onPressed: save,
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

  Widget fishWidget(Fish fish) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: (2000 / fish.speed).round()),
      top: fish.yPos,
      left: fish.xPos,
      child: CircleAvatar(backgroundColor: fish.color),
      onEnd: () {
        
        setState(() {
          fish.randomMove();
        });
      },
    );
  }
}

class Fish {
  Color color;
  double speed;
  double xPos = 100;
  double yPos = 100;

  Fish({required this.color, required this.speed});

  void randomMove() {
    xPos = (xPos + (speed * 10)) % 300;
    yPos = (yPos + (speed * 10)) % 300;
  }
}
