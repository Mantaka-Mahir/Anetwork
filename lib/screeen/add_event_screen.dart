import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ticketsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _couponCodeController = TextEditingController();
  final _couponDiscountController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  bool _hasCoupon = false;

  @override
  void initState() {
    super.initState();
    // Set initial values for date controllers
    _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Use the date objects directly instead of parsing from text
      final startDate = _startDate;
      final endDate = _endDate;

      // Image URL (default or provided)
      String imageUrl = _imageUrlController.text.trim();
      if (imageUrl.isEmpty) {
        imageUrl = 'https://via.placeholder.com/800x400?text=Event+Banner';
      }

      // Create event in Firestore
      final event = Event(
        id: '', // Will be set by Firestore
        name: _nameController.text,
        bannerUrl: imageUrl,
        startDate: startDate,
        endDate: endDate,
        price: double.parse(_priceController.text),
        availableTickets: int.parse(_ticketsController.text),
        createdAt: DateTime.now(),
        ticketsSold: 0,
        isActive: true,
        description: _descriptionController.text,
        hasCoupon: _hasCoupon,
        couponCode: _hasCoupon ? _couponCodeController.text : null,
        couponDiscount:
            _hasCoupon ? double.tryParse(_couponDiscountController.text) : null,
      );

      print('Creating event in Firestore with data: ${event.toMap()}');
      final docRef = await _firestore.collection('events').add(event.toMap());
      print('Event created with ID: ${docRef.id}');

      // Show success and pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error in _createEvent: $e');
      print('Stack trace: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _ticketsController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _couponCodeController.dispose();
    _couponDiscountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Event',
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUrlField(),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Enter a web-hosted image URL. A placeholder will be used if none is provided.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Provide details about the event...',
                ),
                style: GoogleFonts.poppins(),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              // Start Date Picker
              GestureDetector(
                onTap: () => _selectDate(context, isStartDate: true),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a start date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End Date Picker
              GestureDetector(
                onTap: () => _selectDate(context, isStartDate: false),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an end date';
                      }
                      if (_endDate.isBefore(_startDate)) {
                        return 'End date must be after start date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ticketsController,
                decoration: InputDecoration(
                  labelText: 'Total Tickets',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of tickets';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Coupon Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Coupon Discount',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Switch(
                          value: _hasCoupon,
                          activeColor: Colors.red,
                          onChanged: (value) {
                            setState(() {
                              _hasCoupon = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_hasCoupon) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _couponCodeController,
                        decoration: InputDecoration(
                          labelText: 'Coupon Code',
                          hintText: 'e.g. SUMMER20',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        textCapitalization: TextCapitalization.characters,
                        validator: _hasCoupon
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a coupon code';
                                }
                                return null;
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _couponDiscountController,
                        decoration: InputDecoration(
                          labelText: 'Discount Percentage',
                          hintText: 'e.g. 10',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        keyboardType: TextInputType.number,
                        validator: _hasCoupon
                            ? (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter discount percentage';
                                }
                                final discount = double.tryParse(value);
                                if (discount == null) {
                                  return 'Please enter a valid number';
                                }
                                if (discount <= 0 || discount >= 100) {
                                  return 'Discount must be between 0 and 100';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Create Event',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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

  Widget _buildImageUrlField() {
    return TextFormField(
      controller: _imageUrlController,
      decoration: InputDecoration(
        labelText: 'Event Banner URL',
        hintText: 'Enter web-hosted image URL',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.image),
      ),
      style: GoogleFonts.poppins(),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          try {
            final uri = Uri.parse(value);
            if (!uri.hasScheme || !uri.hasAuthority) {
              return 'Please enter a valid URL';
            }
          } catch (e) {
            return 'Please enter a valid URL';
          }
        }
        return null;
      },
    );
  }

  // Add this new method to handle date selection
  Future<void> _selectDate(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = isStartDate ? DateTime.now() : _startDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);

          // If end date is before new start date, update end date too
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
            _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }
}
