import 'package:cryptotracker/constants/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';


class LineChartWidget extends StatelessWidget {
  final List<double> data;
  final Color color;
  final bool loading;
  final bool error;

  const LineChartWidget(
      {Key? key,
      this.data = const [],
      this.color = const Color(0xff45944E),
      this.loading = false,
      this.error = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.center, children: [
      Opacity(
        opacity: data.length > 0 && !loading & !error ? 1 : 0.3,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFF0E0D0C),
            borderRadius: BorderRadius.all(Radius.circular(20))),
          width: double.infinity,
          child: LineChart(
            mainData(data.length > 0 && !loading & !error
                ? data
                : demoGraphData),
            swapAnimationDuration: Duration(seconds: 0),
          ),
        ),
      ),
      if (loading)
        Center(
          child: CircularProgressIndicator(),
        )
      else if (error || data.length == 0)
        Center(
          child: Text("No Result",
              style: Theme.of(context).textTheme.headline3),
        )
    ]);
  }

  final List<int> showIndexes = const [0, 1, 2, 3, 4, 5];

  LineChartData mainData(List<double> data) {
    return LineChartData(
      backgroundColor: Color(0xFF0E0D0C),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: false,
        horizontalInterval: 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: data.length.toDouble() - 1,
      minY: data.reduce(min).toDouble()-1,
      maxY: data.reduce(max).toDouble()+1,
      lineBarsData: [
        LineChartBarData(
          spots: listData(data),
          colors: [color],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradientFrom: Offset(0, .9),
            gradientTo: Offset(0, 0.5),
            colors: [color.withOpacity(.01), color.withOpacity(.3)],
          ),
        ),
      ],
    );
  }

  List<FlSpot> listData(List<double> data) {
    return data
        .mapIndexed((e, i) => FlSpot(i.toDouble(), e.toDouble()))
        .toList();
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
