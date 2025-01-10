import 'package:flutter/material.dart';

class CreditCard extends StatefulWidget {
  final String cardNumber;
  final String cardExpiry;
  final String cardHolderName;
  final String cvv;
  final String bankName;
  final bool showBackSide;
  final Color? frontBackgroundColor; // Single color
  final Gradient? frontBackgroundGradient; // Gradient
  final Color? backBackgroundColor; // Single color
  final Gradient? backBackgroundGradient; // Gradient
  final bool showShadow;

  const CreditCard({
    Key? key,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cardHolderName,
    required this.cvv,
    required this.bankName,
    this.showBackSide = false,
    this.frontBackgroundColor,
    this.frontBackgroundGradient,
    this.backBackgroundColor,
    this.backBackgroundGradient,
    this.showShadow = true,
  }) : super(key: key);

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final cardHeight = cardWidth * 0.6;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
          color: widget.showBackSide
              ? widget.backBackgroundColor
              : widget.frontBackgroundColor,
          gradient: widget.showBackSide
              ? widget.backBackgroundGradient
              : widget.frontBackgroundGradient,
        ),
        height: cardHeight,
        width: cardWidth,
        child: widget.showBackSide ? _buildBackSide() : _buildFrontSide(),
      ),
    );
  }

  Widget _buildFrontSide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.bankName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.cardNumber.replaceAllMapped(
                RegExp(r".{4}"), (match) => "${match.group(0)} "),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Type',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    widget.cardHolderName,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Row(
                    children: [
                      Text(
                        _isObscured ? '****' : widget.cardExpiry,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        child: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.black,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CVV',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                widget.cvv,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
