import 'package:flutter/material.dart';
import 'package:gradecryptmobile/main.dart';

class GradeWindow extends StatelessWidget {
  const GradeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gespeicherte Noten'),
      ),
      body: ListView.builder(
  itemCount: storedGrades.length,
  prototypeItem: ListTile(
    title: Text(storedGrades.first),
  ),
  itemBuilder: (context, index) {
    return ListTile(
      title: Row(
        children: [
          Text((toArray(storedGrades[index])[1]), textScaleFactor: 1.9,),
          Spacer(),
          Text((toArray(storedGrades[index])[0]), textScaleFactor: 1.2,),
          Spacer(),
          Text((toArray(storedGrades[index])[2]), textScaleFactor: 1.2,),
          Text("/", textScaleFactor: 1.2,),
          Text((toArray(storedGrades[index])[3]), textScaleFactor: 1.2,),


        ],
      ),
    );
  },
)
,
    );
  }
}
List<String> toArray(String grades){
  return grades.split(";");
}