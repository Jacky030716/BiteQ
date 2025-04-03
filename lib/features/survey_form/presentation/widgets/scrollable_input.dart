import 'package:biteq/core/theme/_app.Palette.dart';
import 'package:flutter/material.dart';

class SurveyScrollableInput extends StatefulWidget {
  final TextEditingController inputController;
  final Map<String, dynamic> currentQuestion;
  final int minValue;
  final int maxValue;
  final String unit;
  final int? defaultValue;

  const SurveyScrollableInput({
    super.key,
    required this.inputController,
    required this.currentQuestion,
    required this.minValue,
    required this.maxValue,
    this.unit = '',
    this.defaultValue,
  });

  @override
  _SurveyScrollableInputState createState() => _SurveyScrollableInputState();
}

class _SurveyScrollableInputState extends State<SurveyScrollableInput> {
  late int selectedValue;
  late FixedExtentScrollController scrollController;

  @override
  void initState() {
    super.initState();
    final storedValue =
        widget.inputController.text.isNotEmpty
            ? int.tryParse(widget.inputController.text)
            : null;

    // Use stored value if valid, otherwise use default or min value
    selectedValue =
        storedValue != null &&
                storedValue >= widget.minValue &&
                storedValue <= widget.maxValue
            ? storedValue
            : widget.defaultValue != null &&
                widget.defaultValue! >= widget.minValue &&
                widget.defaultValue! <= widget.maxValue
            ? widget.defaultValue!
            : widget.minValue;

    final initialIndex = selectedValue - widget.minValue;
    scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromARGB(232, 250, 250, 250),
            ),
            child: ListWheelScrollView.useDelegate(
              controller: scrollController,
              itemExtent: 70, // Adjusted itemExtent for smoother scrolling
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                final newValue = widget.minValue + index;
                if (newValue != selectedValue) {
                  setState(() {
                    selectedValue = newValue;
                    widget.inputController.text = selectedValue.toString();
                  });
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final value = widget.minValue + index;

                  final distance = (value - selectedValue).abs();
                  final alpha = (255 - (distance * 50)).clamp(50, 255).toInt();

                  return Center(
                    child: Text(
                      '$value ${widget.unit}',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            value == selectedValue
                                ? Palette.primary
                                : Palette.placeholder.withAlpha(alpha),
                      ),
                    ),
                  );
                },
                childCount: widget.maxValue - widget.minValue + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
