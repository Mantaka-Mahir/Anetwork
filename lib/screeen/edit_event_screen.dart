import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/supabase_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  
  const EditEventScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _ticketsController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _supabaseService = SupabaseService();
  final _firestore = FirebaseFirestore.instance;
  final _imagePicker = ImagePicker();
  
  late DateTime startDate;
  late DateTime endDate;
  File? _newImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController.text = widget.event.name;
    _priceController.text = widget.event.price.toString();
    _ticketsController.text = widget.event.availableTickets.toString();
    
    // Initialize the dates
    startDate = widget.event.startDate;
    endDate = widget.event.endDate;
    
    // Set the date controllers with formatted dates
    _startDateController.text = DateFormat('yyyy-MM-dd').format(startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        
        // Check file size (limit to 5MB)
        if (fileSize > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Maximum size is 5MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        
        setState(() {
          _newImageFile = file;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Handle image if changed
      String eventImageUrl = widget.event.bannerUrl;
      
      // Only process image if a new one is selected
      if (_newImageFile != null) {
        // Upload new image to Supabase
        final fileSize = await _newImageFile!.length();
        
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image file is too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Maximum size is 5MB.');
        }
        
        final newImageUrl = await _supabaseService.uploadFile(
          _newImageFile!,
          folder: 'events',
          bucket: SupabaseService.eventImagesBucket,
        );

        if (newImageUrl != null) {
          // If image upload was successful
          eventImageUrl = newImageUrl;
          
          // Only attempt to delete the old image if it's not a placeholder URL and different from the new one
          if (widget.event.bannerUrl.isNotEmpty && 
              !widget.event.bannerUrl.contains('placeholder.com') && 
              widget.event.bannerUrl != newImageUrl) {
            try {
              // Try to delete old image
              await _supabaseService.deleteFile(widget.event.bannerUrl, bucket: SupabaseService.eventImagesBucket);
            } catch (e) {
              print('Warning: Could not delete old image: $e');
              // Continue with update even if deletion fails
            }
          }
        } else {
          // If upload fails, just keep the existing image URL
          print('Image upload failed, keeping existing image');
        }
      }
      
      // Update event in Firestore
      await _firestore.collection('events').doc(widget.event.id).update({
        'name': _nameController.text,
        'bannerUrl': eventImageUrl,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'price': double.parse(_priceController.text),
        'availableTickets': int.parse(_ticketsController.text),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error in _updateEvent: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: $e'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Event",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : TextButton(
                  onPressed: _updateEvent,
                  child: Text(
                    "Save",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image upload section
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                      image: _newImageFile != null
                          ? DecorationImage(
                              image: FileImage(_newImageFile!),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: NetworkImage(widget.event.bannerUrl),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: ClayContainer(
                      color: Colors.white,
                      borderRadius: 50,
                      depth: 20,
                      spread: 2,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Image upload is optional. The current image will be kept if none is selected.",
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
              // Start Date
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
              // End Date
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
                      if (endDate.isBefore(startDate)) {
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
                  labelText: 'Available Tickets',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter available tickets';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to handle date selection
  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime initialDate = isStartDate ? startDate : endDate;
    final DateTime firstDate = isStartDate ? DateTime.now() : startDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          
          // If end date is before new start date, update end date too
          if (endDate.isBefore(startDate)) {
            endDate = startDate.add(const Duration(days: 1));
            _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
          }
        } else {
          endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }
}
