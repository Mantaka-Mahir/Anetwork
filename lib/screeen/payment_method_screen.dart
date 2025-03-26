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
    double ticketPrice = widget.event['price'] ?? 0;
    double totalPrice = widget.ticketsBought * ticketPrice;

    if (couponApplied) {
      totalPrice *= 0.9; // Apply 10% discount
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketConfirmationScreen(
          event: widget.event,
          ticketsBought: widget.ticketsBought,
          totalPrice: totalPrice,
          couponApplied: couponApplied,
        ),
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

    // Apply coupon discount if any
    if (couponApplied) {
      totalPrice *= 0.9; // 10% discount
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
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

              // Event Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event['title'] ?? "Event Name",
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tickets: ${widget.ticketsBought}",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Price:",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),  // Change this to Colors.black
                        ),
                        Text(
                          "৳ ${totalPrice.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),  // Change this to Colors.black
                        ),
                      ],
                    )

                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Select Payment Method",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              /// Payment Methods
              _buildPaymentCard("Credit Card", "https://cdn-icons-png.flaticon.com/512/217/217841.png"),
              _buildPaymentCard("PayPal", "https://cdn-icons-png.flaticon.com/512/888/888870.png"),

              const SizedBox(height: 20),

              /// Coupon Section
              Text(
                "Enter Coupon Code",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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

              /// Confirm Payment Button
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
