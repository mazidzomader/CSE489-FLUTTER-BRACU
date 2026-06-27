import 'package:flutter/material.dart';
import 'sizes.dart';

void main() {
  runApp(const VangtiChaiApp());
}

class VangtiChaiApp extends StatelessWidget {
  const VangtiChaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VangtiChai',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BF63),
          brightness: Brightness.dark,
          primary: const Color(0xFF00BF63),
          secondary: const Color(0xFFFF6F00),
          surface: const Color(0xFF121212),
        ),
        fontFamily: 'Roboto',
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const VangtiChaiHomePage(),
    );
  }
}

class VangtiChaiHomePage extends StatefulWidget {
  const VangtiChaiHomePage({super.key});

  @override
  State<VangtiChaiHomePage> createState() => _VangtiChaiHomePageState();
}

class _VangtiChaiHomePageState extends State<VangtiChaiHomePage> {
  // Retained automatically across screen rotation rebuilds
  String _currentAmount = "";

  // Required Taka note breakdown denominations
  final List<int> _denominations = const [500, 100, 50, 20, 10, 5, 2, 1];

  void _onDigitPress(String digit) {
    // Ceiling of 15 digits to allow huge amounts up to quadrillions without int overflow
    if (_currentAmount.length >= 15) return;

    setState(() {
      if (_currentAmount == "0" || _currentAmount.isEmpty) {
        _currentAmount = digit;
      } else {
        _currentAmount += digit;
      }
    });
  }

  void _onClear() {
    setState(() {
      _currentAmount = "";
    });
  }

  void _onBackspace() {
    setState(() {
      if (_currentAmount.isNotEmpty) {
        _currentAmount = _currentAmount.substring(0, _currentAmount.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    // Fetch dynamic dimension resources based on device size & orientation
    final sizes = AppSizes.get(shortestSide, isLandscape);

    return Scaffold(
      backgroundColor: const Color(0xFF181A1B),
      appBar: AppBar(
        title: const Text(
          'VangtiChai Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F2223),
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(sizes.screenPadding),
          child: Column(
            children: [
              _buildTopSection(sizes),
              SizedBox(height: sizes.sectionSpacing),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Side: Denomination Table
                    Expanded(flex: 10, child: _buildBreakdownTable(sizes)),
                    SizedBox(width: sizes.sectionSpacing),
                    // Right Side: Custom Keypad
                    Expanded(flex: 11, child: _buildKeypad(sizes)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(AppSizes sizes) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: sizes.screenPadding,
        vertical: sizes.sectionSpacing,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Taka:',
            style: TextStyle(
              fontSize: sizes.topLabelTextSize,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: sizes.labelAmountSpacing),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _currentAmount.isEmpty ? '0' : _currentAmount,
                style: TextStyle(
                  fontSize: sizes.topAmountTextSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00FF87),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTable(AppSizes sizes) {
    final int totalAmount = int.tryParse(_currentAmount) ?? 0;
    int remaining = totalAmount;
    final List<int> counts = [];
    for (final note in _denominations) {
      counts.add(remaining ~/ note);
      remaining %= note;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242729),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            height: sizes.tableHeaderHeight,
            decoration: const BoxDecoration(color: Color(0xFF00695C)),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Note',
                      style: TextStyle(
                        fontSize: sizes.tableHeaderTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Count',
                      style: TextStyle(
                        fontSize: sizes.tableHeaderTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          Expanded(
            child: Column(
              children: List.generate(_denominations.length, (index) {
                final note = _denominations[index];
                final count = counts[index];

                return Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white10)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.tableCellPaddingHorizontal,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              '$note',
                              style: TextStyle(
                                fontSize: sizes.tableRowTextSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: sizes.tableRowTextSize,
                                fontWeight: count > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: count > 0
                                    ? const Color(0xFF00E676)
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(AppSizes sizes) {
    final grid = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['CLEAR', '0', 'BACKSPACE'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242729),
        border: Border.all(color: Colors.white12),
      ),
      padding: EdgeInsets.all(sizes.keypadBtnMargin * 2),
      child: Column(
        children: grid.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                final isClear = label == 'CLEAR';
                final isBackspace = label == 'BACKSPACE';

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(sizes.keypadBtnMargin),
                    child: Material(
                      color: isClear
                          ? const Color(0xFFD84315)
                          : (isBackspace
                                ? const Color(0xFF455A64)
                                : const Color(0xFF37474F)),
                      elevation: 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (isClear) {
                            _onClear();
                          } else if (isBackspace) {
                            _onBackspace();
                          } else {
                            _onDigitPress(label);
                          }
                        },
                        child: Center(
                          child: isBackspace
                              ? Icon(
                                  Icons.backspace_outlined,
                                  color: Colors.white,
                                  size: sizes.keypadBtnTextSize,
                                )
                              : Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: isClear
                                        ? sizes.keypadClearTextSize
                                        : sizes.keypadBtnTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
