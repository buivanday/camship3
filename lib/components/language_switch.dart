import 'package:flutter/material.dart';

class LanguageSwitch extends StatefulWidget {
  @required
  final List<String> options;
  @required
  final String selectedOption;
  @required
  final Function onSelect;
  @required
  final Color selectedBackgroundColor;
  @required
  final Color selectedTextColor;
  @required
  final EdgeInsets margin;
  @required
  final EdgeInsets padding;

  const LanguageSwitch({
    Key key,
    this.options,
    this.selectedOption,
    this.onSelect,
    this.selectedBackgroundColor,
    this.selectedTextColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  _LanguageSwitchState createState() => new _LanguageSwitchState();
}

class _LanguageSwitchState extends State<LanguageSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: widget.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              padding: widget.padding,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                ),
              ),
              textColor: widget.selectedOption == widget.options[0]
                  ? widget.selectedTextColor
                  : Colors.black,
              splashColor: widget.selectedOption == widget.options[0]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              color: widget.selectedOption == widget.options[0]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              highlightColor: widget.selectedOption == widget.options[0]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              child: Container(
                alignment: Alignment.center,
                child: Text(widget.options[0]),
              ),
              onPressed: () => widget.onSelect(widget.options[0]),
            ),
          ),
          Expanded(
            child: RaisedButton(
              padding: widget.padding,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
              textColor: widget.selectedOption == widget.options[1]
                  ? widget.selectedTextColor
                  : Colors.black,
              splashColor: widget.selectedOption == widget.options[1]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              color: widget.selectedOption == widget.options[1]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              highlightColor: widget.selectedOption == widget.options[1]
                  ? widget.selectedBackgroundColor
                  : Colors.white,
              child: Container(
                alignment: Alignment.center,
                child: Text(widget.options[1],maxLines: 1,),
              ),
              onPressed: () => widget.onSelect(widget.options[1]),
            ),
          ),
        ],
      ),
    );
  }
}
