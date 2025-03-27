import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clay_containers/clay_containers.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  File? _bannerImage;

  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  // Dummy save method (you can later integrate this with your backend or state management)
  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // For now, just show a confirmation message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Event added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate back or clear the form if needed.
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Event",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          // Save button in AppBar
          TextButton(
            onPressed: _saveEvent,
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
              GestureDetector(
                onTap: _pickImage,
                child: ClayContainer(
                  depth: 30,
                  borderRadius: 15,
                  color: Colors.grey[200],
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey),
                      image: _bannerImage != null
                          ? DecorationImage(
                        image: FileImage(_bannerImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _bannerImage == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            "Upload Event Banner",
                            style: GoogleFonts.poppins(
                                color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Event Name Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter event name' : null,
              ),
              const SizedBox(height: 16),
              // Date Field
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    selectedDate.toString().split(' ')[0],
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Price Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixText: '৳ ',
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter price' : null,
              ),
              const SizedBox(height: 16),
              // Total Tickets Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Total Tickets',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter total tickets' : null,
              ),
              const SizedBox(height: 16),
              // Coupon Codes Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Coupon Codes (comma separated)',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
