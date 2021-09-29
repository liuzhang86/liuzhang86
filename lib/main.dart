import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var data = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ];



  List<RectModel> _getCoordinates(double width, double height) {
    List<RectModel> rectModels = List();
    double w = width / 22;
    double h = height / 18;
    for (int i = 0; i < 18; i++) { //行 row
      for (int j = 0; j < 22; j++) { //列 colum
        double x1 = w * j;
        double y1 = h * i;
        double x2 = w * (j + 1);
        double y2 = h * (i + 1);
        RectModel model = RectModel(Offset(x1, y1), Offset(x2, y2),i, j);
        rectModels.add(model);
      }
    }
    return rectModels;
  }

  void _getSelectRectModels(
      double x, double y, List<RectModel> normalRectModels, bool isDelete) {
    if (x != null && y != null && normalRectModels.length > 0) {
      normalRectModels.forEach((element) {
        double x1 = element.startPoint.dx;
        double y1 = element.startPoint.dy;
        double x2 = element.endPoint.dx;
        double y2 = element.endPoint.dy;
        if (x - x1 >= 0 && y - y1 >= 0 && x2 - x >= 0 && y2 - y >= 0) {
          if(isDelete == true){
            //删除
            if(selectRectModels.contains(element)){
              selectRectModels.remove(element);
            }
          }else{
            //添加
            if (!selectRectModels.contains(element)) {
              selectRectModels.add(element);
            }
          }
          print("row:${element.row} colum:${element.colum}");
        }
      });
    }
  }

  List<RectModel> selectRectModels = List();
  List<RectModel> normalRectModels = List();
  bool isLineClear = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.width * 9 / 16;

    if(normalRectModels.length == 0){
      normalRectModels = _getCoordinates(width, height);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          Offset localPosition = details.localPosition;
          double x = localPosition.dx;
          double y = localPosition.dy;
          print("移动:$x,$y");
          setState(() {
            _getSelectRectModels(x, y, normalRectModels,isLineClear);
          });
        },
        onTapDown: (TapDownDetails details) {
          Offset localPosition = details.localPosition;
          double x = localPosition.dx;
          double y = localPosition.dy;
          print("点击:$x,$y");
          setState(() {
            _getSelectRectModels(x, y, normalRectModels,isLineClear);
          });
        },
        child: Column(
          children: [
            Container(
              width: width,
              height: height,
              color: Colors.green,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: BackGroundPainter(width,height),
                    foregroundPainter: SignaturePainter(selectRectModels),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50,),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                      onPressed: () {
                        setState(() {
                          isLineClear = true;
                        });
                      },
                      child: Text('刷涂清除'),
                    ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            selectRectModels.clear();
                            isLineClear = false;
                          });
                        },
                        child: Text('全部清除'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            isLineClear = false;
                          });
                        },
                        child: Text('画线添加'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          var data = List();
                          for(int i = 0; i < 18; i++){
                            List elemen = List();
                            for(int j = 0; j < 22; j++){
                              elemen.add(0);
                            }
                            data.add(elemen);
                          }
                          selectRectModels.forEach((element) {
                            data[element.row][element.colum] = 1;
                          });
                          print(data);
                          for(int i = 0; i < data.length; i++){
                            int total = 0;
                            int length = data[i].length;
                            for(int j = 0; j < length; j++){
                              total = total + data[i][j] * pow(2,j);
                            }
                            print("区域$i:$total 0x${total.toRadixString(16)}");
                          }
                        },
                        child: Text('保存数据'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          
                          List testData = List();
                          for(int i = 0; i < 18; i++){
                            if(i == 0){
                              testData.add(0x1f00);
                            }else{
                              testData.add(0);
                            }
                          }

                          List a1 = List();
                          List a2 = List();
                          normalRectModels.forEach((element) {
                            a2.add(element);
                            if(element.colum == 21){
                              a1.add(a2);
                              a2 = List();
                            }
                          });

                          setState(() {
                            selectRectModels.clear();

                            for(int i = 0; i <testData.length; i++){ //18行
                              List <String> res = testData[i].toRadixString(2).split("").reversed.toList();
                              print(res);
                              for(int j = 0; j < res.length; j ++){
                                if(int.tryParse(res[j]) == 1){
                                  selectRectModels.add(a1[i][j]);
                                }
                              }
                            }
                          });
                        },
                        child: Text('获取数据'),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class BackGroundPainter extends CustomPainter {
  final double width;
  final double height;

  const BackGroundPainter(this.width, this.height);

  void paint(Canvas canvas, Size size) {
    Paint _paint = Paint()
      ..isAntiAlias = true //是否扛锯齿
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke //绘制模式，画线或充满
      ..color = Colors.deepOrange //画笔颜色
      ..invertColors = false;

    for (int i = 0; i < 19; i++) {
      canvas.drawLine(Offset(0, i * (height / 18)),
          Offset(width, i * (height / 18)), _paint);
    }
    for (int i = 0; i < 23; i++) {
      canvas.drawLine(Offset(i * (width / 22), 0),
          Offset(i * (width / 22), height), _paint);
    }
    print('重绘: w:$width, height:$height');
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SignaturePainter extends CustomPainter {
  final List<RectModel> selectPoints;
  SignaturePainter(this.selectPoints);
  void paint(Canvas canvas, Size size) {
    Paint _selectPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..invertColors = false;

    selectPoints.forEach((element) {
      Rect rect = Rect.fromPoints(element.startPoint, element.endPoint);
      canvas.drawRect(rect, _selectPaint);
    });
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class RectModel {
  final Offset startPoint;
  final Offset endPoint;
  final int row;
  final int colum;
  RectModel(this.startPoint, this.endPoint, this.row, this.colum);
}
