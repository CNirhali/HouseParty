import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class PartyDetailScreen extends StatefulWidget {
  final Party party;
  final int userId;

  PartyDetailScreen({required this.party, required this.userId});

  @override
  _PartyDetailScreenState createState() => _PartyDetailScreenState();
}

class _PartyDetailScreenState extends State<PartyDetailScreen> {
  final ApiService apiService = ApiService();
  bool isBooking = false;
  bool isBooked = false;
  String? secretAddress; // To be revealed

  Future<void> _bookParty() async {
    setState(() {
      isBooking = true;
    });

    try {
      bool success = await apiService.bookParty(widget.userId, widget.party.id);
      if (success) {
        setState(() {
          isBooked = true;
          isBooking = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully booked! Address revealed 2 hrs before.')),
        );
        // Auto-reveal for MVP demonstration purposes
        _revealAddress();
      }
    } catch (e) {
      setState(() {
        isBooking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed.')),
      );
    }
  }

  Future<void> _revealAddress() async {
    // In a real app, logic would ensure this is only callable < 2 hours before
    try {
      // Mock booking ID assuming our booking ID is returned, but we hack it for MVP
      // In a real flow, the /bookings/ endpoint returns the booking ID, which we save.
      // Assuming a generic mock behavior or direct address fetch.
      // For this script, we'll simulate the secret address reveal by pretending booking ID is 1
      final revealedParty = await apiService.getSecretAddress(1); 
      setState(() {
        secretAddress = revealedParty.address;
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.party.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              color: Colors.purple[100],
              child: Center(
                child: Icon(Icons.celebration, size: 80, color: Colors.purple),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vibe Rating',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(widget.party.vibe, style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.purple,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(DateFormat('EEEE, MMM dd').format(widget.party.dateTime)),
                    subtitle: Text(DateFormat('hh:mm a').format(widget.party.dateTime)),
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('${widget.party.currentGuests} / ${widget.party.maxGuests} Guests Verified'),
                    subtitle: Text('Identity verified by District Mobile App'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Secret Location'),
                    subtitle: Text(
                      secretAddress != null 
                        ? secretAddress! 
                        : (isBooked ? 'Address processing...' : 'Address locked. Book to unlock.'),
                      style: TextStyle(
                        fontWeight: secretAddress != null ? FontWeight.bold : FontWeight.normal,
                        color: secretAddress != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (!isBooked)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isBooking ? null : _bookParty,
                      child: isBooking 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Request to Join (Digital Doorbell)', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  if (isBooked)
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.green[100],
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('You are on the guest list!'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
