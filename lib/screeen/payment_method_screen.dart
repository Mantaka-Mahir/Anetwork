import 'package:event_management_app/screeen/confarmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final int ticketsBought;

  const PaymentMethodScreen({Key? key, required this.event, required this.ticketsBought})
      : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedPaymentMethod = 'Credit Card';
  final TextEditingController couponController = TextEditingController();
  bool couponApplied = false;

  void _applyCoupon() {
    if (couponController.text.trim().toUpperCase() == 'DISCOUNT10') {
      setState(() {
        couponApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon Applied! 10% discount applied.')),
      );
    } else {
      setState(() {
        couponApplied = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code.')),
      );
    }
  }

  void _confirmPayment() {
    double ticketPrice = widget.event['ticketPrice'] ?? 0;
    double totalPrice = widget.ticketsBought * ticketPrice;

    if (couponApplied) {
      totalPrice *= 0.9; // Apply 10% discount
    }

    // Using a fade transition when navigating to the confirmation screen
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => TicketConfirmationScreen(
          event: widget.event,
          ticketsBought: widget.ticketsBought,
          totalPrice: totalPrice,
          couponApplied: couponApplied,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = name;
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: selectedPaymentMethod == name ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selectedPaymentMethod == name ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            if (selectedPaymentMethod == name)
              const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double ticketPrice = widget.event['ticketPrice'] ?? 0;
    double totalPrice = widget.ticketsBought * ticketPrice;

    if (couponApplied) {
      totalPrice *= 0.9; // Apply coupon discount
    }

    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text("Payment Methods"),
        elevation: 0,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Enhanced Event Details Container with background image, gradient overlay, rounded corners, and padding.
              GestureDetector(
                onTap: () {
                  // Optional: If you want the container to be tappable to show more details.
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.event['image'] ??
                            'https://via.placeholder.com/400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.event['title'] ?? "Event Name",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tickets: ${widget.ticketsBought}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "৳ ${totalPrice.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildPaymentCard("Credit Card", "https://cdn-icons-png.flaticon.com/512/217/217841.png"),
              _buildPaymentCard("PayPal", "https://cdn-icons-png.flaticon.com/512/888/888870.png"),
              const SizedBox(height: 20),
              Text(
                "Enter Coupon Code",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: "Enter coupon code",
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Apply"),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Confirm Payment",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
