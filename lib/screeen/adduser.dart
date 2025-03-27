import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";
  String _phone = "";
  String _ticketCount = "";

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Dummy submission: You can add your logic here.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User added: $_name, $_email, $_phone, Tickets: $_ticketCount"),
          backgroundColor: Colors.green,
        ),
      );
      // Optionally navigate back or clear the form.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add User", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter a name" : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter an email" : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              // Phone Number Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter a phone number" : null,
                onSaved: (value) => _phone = value!,
              ),
              const SizedBox(height: 16),
              // Ticket Count Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Number of Tickets",
                  labelStyle: GoogleFonts.poppins(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter ticket count";
                  }
                  if (int.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
                onSaved: (value) => _ticketCount = value!,
              ),
              const SizedBox(height: 24),
              // Add User Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Add User",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
