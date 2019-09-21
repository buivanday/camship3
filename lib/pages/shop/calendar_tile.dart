import 'package:farax/components/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final Widget child;
  final bool hasBilling;

  CalendarTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek: false,
    this.isSelected: false,
    this.hasBilling: false
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    if (isDayOfWeek) {
      return new InkWell(
        child: new Container(
          alignment: Alignment.center,
          child: new Text(
            dayOfWeek,
            style: dayOfWeekStyles,
          ),
        ),
      );
    } else {
      return new InkWell(
        onTap: onDateSelected,
        child: Stack(
          children: <Widget>[
            Container(
              decoration: isSelected
                  ? new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(0, 153, 204, 0.16),
                    )
                  : new BoxDecoration(),
              alignment: Alignment.center,
              child: new Text(
                Utils.formatDay(date).toString(),
                style: isSelected ? new TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold, fontSize: 16.0) : TextStyle(color: HexColor('#455A64'), fontSize: 16.0, height: 19.0/16.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return new InkWell(
        child: child,
        onTap: onDateSelected,
      );
    }
    return !isDayOfWeek ? Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(4.0),
            child: renderDateOrDayOfWeek(context),
          ),
          hasBilling ? Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Icon(Icons.lens, size: 10, color: HexColor('#FF9933'),),
          ) : Container(),
        ],
    ) : Container(
      child: renderDateOrDayOfWeek(context),
    );
  }
}
