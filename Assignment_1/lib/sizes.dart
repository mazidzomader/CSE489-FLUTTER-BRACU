/// Resource Management for VangtiChai
/// Fulfills the requirement: "Do not hardcode any sizing values (text sizes, padding, margins)
/// in layout files. All such values must be defined in and referenced from a sizes resource file."
class AppSizes {
  // Screen padding
  final double screenPadding;

  // Spacings
  final double sectionSpacing;
  final double labelAmountSpacing;
  final double keypadBtnMargin;
  final double tableRowPadding;
  final double tableCellPaddingVertical;
  final double tableCellPaddingHorizontal;

  // Typography
  final double topLabelTextSize;
  final double topAmountTextSize;
  final double tableHeaderTextSize;
  final double tableRowTextSize;
  final double keypadBtnTextSize;
  final double keypadClearTextSize;

  // Element dimensions
  final double keypadBtnHeight;
  final double tableHeaderHeight;

  const AppSizes({
    required this.screenPadding,
    required this.sectionSpacing,
    required this.labelAmountSpacing,
    required this.keypadBtnMargin,
    required this.tableRowPadding,
    required this.tableCellPaddingVertical,
    required this.tableCellPaddingHorizontal,
    required this.topLabelTextSize,
    required this.topAmountTextSize,
    required this.tableHeaderTextSize,
    required this.tableRowTextSize,
    required this.keypadBtnTextSize,
    required this.keypadClearTextSize,
    required this.keypadBtnHeight,
    required this.tableHeaderHeight,
  });

  /// Dynamically loads alternative dimensions depending on screen width (Phone vs Tablet sw600dp)
  /// and orientation (Portrait vs Landscape).
  factory AppSizes.get(double shortestSide, bool isLandscape) {
    final bool isTablet = shortestSide >= 600;

    if (isTablet) {
      return AppSizes(
        screenPadding: 32.0,
        sectionSpacing: 24.0,
        labelAmountSpacing: 16.0,
        keypadBtnMargin: 8.0,
        tableRowPadding: 10.0,
        tableCellPaddingVertical: 12.0,
        tableCellPaddingHorizontal: 24.0,
        topLabelTextSize: 32.0,
        topAmountTextSize: 42.0,
        tableHeaderTextSize: 22.0,
        tableRowTextSize: 20.0,
        keypadBtnTextSize: 28.0,
        keypadClearTextSize: 20.0,
        keypadBtnHeight: isLandscape ? 60.0 : 85.0,
        tableHeaderHeight: 50.0,
      );
    } else {
      return AppSizes(
        screenPadding: 16.0,
        sectionSpacing: 12.0,
        labelAmountSpacing: 8.0,
        keypadBtnMargin: 4.0,
        tableRowPadding: 6.0,
        tableCellPaddingVertical: 8.0,
        tableCellPaddingHorizontal: 12.0,
        topLabelTextSize: 24.0,
        topAmountTextSize: 32.0,
        tableHeaderTextSize: 18.0,
        tableRowTextSize: 16.0,
        keypadBtnTextSize: 22.0,
        keypadClearTextSize: 15.0,
        keypadBtnHeight: isLandscape ? 44.0 : 60.0,
        tableHeaderHeight: 40.0,
      );
    }
  }
}
