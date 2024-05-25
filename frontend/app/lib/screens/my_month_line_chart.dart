import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyMonthLineChart extends StatelessWidget {
  final Color lineColor;
  final List<FlSpot> spots;
  final Map<int, String> dayNames = {
    1: '          30일 전',
    5: '',
    10: '      20일 전',
    15: '',
    20: '10일 전',
    25: '',
    30: '어제       ',
  };

  MyMonthLineChart({
    Key? key,
    required this.lineColor,
    required this.spots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == 25 || value == 50) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 128, 128, 128),
                      fontSize: 12,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  dayNames[value.toInt()] ?? '',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 128, 128, 128),
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Color.fromARGB(255, 201, 201, 201),
            width: 1,
          ),
        ),
        minX: 1,
        maxX: 30,
        minY: 0,
        maxY: 50,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class MyMonthLineChart extends StatelessWidget {
//   final Color lineColor;
//   final List<FlSpot> spots;
//   final Map<int, String> dayNames = {
//     1: '          30일 전',
//     5: '',
//     10: '      20일 전',
//     15: '',
//     20: '10일 전',
//     25: '',
//     30: '어제       ',
//   };

//   MyMonthLineChart({
//     Key? key,
//     required this.lineColor,
//     required this.spots,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         gridData: const FlGridData(show: false),
//         titlesData: FlTitlesData(
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           rightTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value == 0 || value == 25 || value == 50) {
//                   return Text(
//                     value.toInt().toString(),
//                     style: const TextStyle(
//                       color: Color.fromARGB(255, 128, 128, 128),
//                       fontSize: 12,
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//               reservedSize: 30,
//             ),
//           ),
//           topTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   dayNames[value.toInt()] ?? '',
//                   style: const TextStyle(
//                     color: Color.fromARGB(255, 128, 128, 128),
//                     fontSize: 12,
//                   ),
//                 );
//               },
//               reservedSize: 30,
//             ),
//           ),
//         ),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(
//             color: const Color(0xFFECECEC),
//             width: 1,
//           ),
//         ),
//         minX: 1,
//         maxX: 30,
//         minY: 0,
//         maxY: 50,
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             color: lineColor,
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: const FlDotData(
//               show: false,
//             ),
//             belowBarData: BarAreaData(
//               show: false,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }