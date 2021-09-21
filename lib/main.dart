import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Indicator.dart';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  
  static List? audience=[];
  static String? _chosenCible="blo" ;
  static bool? _chosenTH = true;

  static List? audience_filtered=[];

  var _chaines=["AL AOULA","2M","Autres chaines SNRT","AL MAGHRIBIA","Total Autres Chaines"];  
  
  int? sortColumnIndex = 0;
  bool isAscending = true ;
  int touchedIndex = -1;
  Future<String>_loadAudienceAsset() async{
  return await rootBundle.loadString('../assets/Audience.json');
  }

  Future loadAudience() async {
    final String jsonString = await _loadAudienceAsset();
    final jsonResponse = json.decode(jsonString);
    
      setState(() {
        audience = jsonResponse["Full"];
         
        audience_filtered = audience?.where((val) =>_chaines.contains(val["Chaine"])
           &&(val['Cible'] == "Individus 5+") &&(!val['prime_time'])
         ).toList();

         _chosenCible = "Individus 5+";
         _chosenTH = false;
 
      });
    }
  
  @override
    void initState() {
      super.initState();
      loadAudience();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
           children: [
            Text(
              'Audience',
              style: TextStyle(color: Color(0xff0293ee),fontSize: 40.0,fontWeight:FontWeight.bold)
            ),
               Padding(padding: const EdgeInsets.all(20), 
               child:Row(
                children: [
                ElevatedButton(onPressed: loadAudience, child: Text('Reset'), style: ElevatedButton.styleFrom(
                  primary: Color(0xff845bef),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  )
                ),),
                Padding(padding: const EdgeInsets.all(10)),
                DropdownButton<String>(
                    style: TextStyle(color: Colors.black),
                    items: <String>["Individus 5+", "Femmes 5 ans et +", "Hommes 5 ans et +", "Femmes 15 ans et +", "Hommes 15 ans et +"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    hint: Text(
                      _chosenCible!.isEmpty ?  "Cible" :_chosenCible! ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    dropdownColor: Colors.grey,
                    icon: Icon(Icons.arrow_drop_down_circle),
                    iconSize: 23,
                    underline: SizedBox(),
                    onChanged: (String? value){
                       setState(() {
                        // loadAudience(); 
                         _chosenCible = value;
                        _chosenTH=false;
                        audience_filtered = audience?.where((val) => _chaines.contains(val["Chaine"]) && val["Cible"].contains(_chosenCible) && val['prime_time']==false).toList();
                        print(audience_filtered);
                      });
                    },
                ),
                DropdownButton<bool>(
                    style: TextStyle(color: Colors.black),
                    items: <bool>[true, false].map<DropdownMenuItem<bool>>((bool value) {
                      return DropdownMenuItem<bool>(
                        value: value,
                        child: Text(value.toString(), style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    hint:Text(
                      _chosenTH! ?  "Prime Time" : "Total Journée"
                      ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    dropdownColor: Colors.grey,
                    icon: Icon(Icons.arrow_drop_down_circle),
                    iconSize: 23,
                    underline: SizedBox(),
                    // isExpanded: true,
                    
                    onChanged: (bool? value){
                       setState(() {
                         _chosenTH = value;
                        print(_chosenCible);
                        
                          if (_chosenCible!.isEmpty){
                          audience_filtered = audience?.where((val) => _chaines.contains(val["Chaine"]) && val["prime_time"] == _chosenTH).toList(); 
                          print(audience_filtered);
                          }else{
                            audience_filtered = audience?.where((val) => _chaines.contains(val["Chaine"]) && val['Cible'].contains(_chosenCible)   && val["prime_time"] == _chosenTH).toList(); 
                          print(audience_filtered);
                          
                          }
                       
                      });
                    },
              ),
          ],
          ),
          ),
        Card(
          child: Card(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 22,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 0.8,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: showingSections()
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Indicator(
                  color: Color(0xff0293ee),
                  text: '2M',
                  isSquare: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xfff8b250),
                  text: 'Aloula',
                  isSquare: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff845bef),
                  text: 'Almaghribia',
                  isSquare: false,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff13d38e),
                  text: 'Autre Chaine SNRT',
                  isSquare: false,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
          
          
        ),
           ]
           )
        ),
        ),
      
    );
  }


  List<PieChartSectionData> showingSections() {
  
    return audience_filtered!.asMap().entries.map((entry){
      
      int index = entry.key;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 27.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      var test = entry.value;
      var _countdouble = test['PDA%'].toDouble();
      return PieChartSectionData(
       value: _countdouble,
      title: '',
      radius: radius,
      badgeWidget: Text(
        '${(_countdouble).toStringAsFixed(2)}%',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isTouched ? Colors.black : Color(0xffffffff),
        ),
      ),
      badgePositionPercentageOffset: .80);
    }).toList();
    
  }
}


