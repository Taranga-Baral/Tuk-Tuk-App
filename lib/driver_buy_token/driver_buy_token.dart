import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TokenPurchasePage extends StatefulWidget {
  const TokenPurchasePage({super.key});

  @override
  State<TokenPurchasePage> createState() => _TokenPurchasePageState();
}

class _TokenPurchasePageState extends State<TokenPurchasePage>
    with SingleTickerProviderStateMixin {
  String? _selectedPaymentMethod;
  double _currentAmount = 999;
  final List<double> _amountOptions = [99, 999, 1999, 4999];
  bool _isProcessing = false;
  bool _showPaymentOptions = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePaymentOptions() {
    setState(() {
      _showPaymentOptions = !_showPaymentOptions;
      if (_showPaymentOptions) {
        _animationController.forward();
        // Scroll to show payment options when opened
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buy Tokens',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Payment Method Card - Custom Dropdown
                    GestureDetector(
                      onTap: _togglePaymentOptions,
                      child: Card(
                        elevation: 1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Method',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedPaymentMethod ??
                                          'Select Payment Method',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight:
                                            _selectedPaymentMethod != null
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                        color: _selectedPaymentMethod != null
                                            ? Colors.grey.shade900
                                            : Colors.grey.shade500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  RotationTransition(
                                    turns: _showPaymentOptions
                                        ? const AlwaysStoppedAnimation(0.5)
                                        : const AlwaysStoppedAnimation(0),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Payment Options Dropdown with animation
                    if (_showPaymentOptions) ...[
                      const SizedBox(height: 4),
                      Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPaymentOption(
                                'Esewa', Icons.account_balance_wallet),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0x292E3E3E)),
                            _buildPaymentOption(
                                'Khalti', Icons.mobile_friendly),
                            const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0x292E3E3E)),
                            _buildPaymentOption(
                                'Bank Transfer', Icons.account_balance),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Amount Selection Card
                    Expanded(
                      child: Card(
                        elevation: 1,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Amount',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Amount controls with +/-
// In your build method, replace the Row with +/- buttons and Slider with this:

// Amount controls with +/-
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.redAccent,
                                    iconSize: 32,
                                    onPressed: () {
                                      setState(() {
                                        final currentIndex = _amountOptions
                                            .indexOf(_currentAmount);
                                        if (currentIndex > 0) {
                                          _currentAmount =
                                              _amountOptions[currentIndex - 1];
                                        }
                                      });
                                    },
                                  ),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      'NPR ${_currentAmount.toStringAsFixed(0)}',
                                      key: ValueKey<double>(
                                          _currentAmount), // Important for animation
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.redAccent,
                                    iconSize: 32,
                                    onPressed: () {
                                      setState(() {
                                        final currentIndex = _amountOptions
                                            .indexOf(_currentAmount);
                                        if (currentIndex <
                                            _amountOptions.length - 1) {
                                          _currentAmount =
                                              _amountOptions[currentIndex + 1];
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),

// Slider with exact value snapping
                              // Custom slider that properly handles non-linear values
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.redAccent,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  thumbColor: Colors.redAccent,
                                  overlayColor: Colors.redAccent.withAlpha(32),
                                  valueIndicatorColor: Colors.redAccent,
                                  showValueIndicator: ShowValueIndicator.always,
                                ),
                                child: Slider(
                                  value: _amountOptions
                                      .indexOf(_currentAmount)
                                      .toDouble(),
                                  min: 0,
                                  max: (_amountOptions.length - 1).toDouble(),
                                  divisions: _amountOptions.length - 1,
                                  label:
                                      'NPR ${_currentAmount.toStringAsFixed(0)}',
                                  onChanged: (double value) {
                                    final index = value.round();
                                    setState(() {
                                      _currentAmount = _amountOptions[index];
                                    });
                                  },
                                ),
                              ),

                              // Quick select buttons
                              const SizedBox(height: 8),
                              Text(
                                'Quick Select:',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 10,
                                runSpacing: 12,
                                children: _amountOptions.map((amount) {
                                  final isSelected = amount == _currentAmount;
                                  final isSpecialOffer = amount == 4999;
                                  final isSmallestAmount = amount == 99;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentAmount = amount;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.redAccent.withOpacity(0.1)
                                            : Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.redAccent
                                              : Colors.grey.shade200,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'NPR ${amount.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.redAccent
                                                  : Colors.grey.shade800,
                                            ),
                                          ),
                                          if (isSpecialOffer) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '20% OFF',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isSmallestAmount) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Starter',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              // Bonus information
                              if (_currentAmount == 4999) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Special offer! Get 20% more tokens with this package.',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Token calculation preview
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You will receive:',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tokens',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                              _calculateTokens(_currentAmount)
                                  .toStringAsFixed(0),
                              key: ValueKey<double>(_currentAmount),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons - Always visible at bottom
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed:
                                _selectedPaymentMethod == null || _isProcessing
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isProcessing = true;
                                        });

                                        await Future.delayed(
                                            const Duration(seconds: 2));

                                        setState(() {
                                          _isProcessing = false;
                                        });

                                        _showPaymentSuccessDialog();
                                      },
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Proceed to Pay',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return ListTile(
      leading: Icon(icon,
          color: method == 'Esewa'
              ? Colors.green
              : method == 'Khalti'
                  ? Colors.purple
                  : Colors.blueAccent),
      title: Text(
        method,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
          _showPaymentOptions = false;
          _animationController.reverse();
        });
      },
    );
  }

  double _calculateTokens(double amount) {
    if (amount == 4999) {
      return amount * 1.2; // 20% bonus
    }
    return amount * 0.9;
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You have received ${_calculateTokens(_currentAmount).toStringAsFixed(0)} tokens.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for your purchase!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
