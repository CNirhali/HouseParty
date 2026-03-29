import 'package:flutter/material.dart';
import '../models/party_model.dart';
import '../services/api_service.dart';
import 'party_detail_screen.dart';
import 'package:intl/intl.dart';

class PartyFeedScreen extends StatefulWidget {
  @override
  _PartyFeedScreenState createState() => _PartyFeedScreenState();
}

class _PartyFeedScreenState extends State<PartyFeedScreen> {
  final ApiService apiService = ApiService();
  List<Party> parties = [];
  bool isLoading = true;
  String? selectedVibe;

  // Mock user location for MVP
  final double userLat = 28.7041;
  final double userLng = 77.1025;
  final int currentUserId = 1; // Mock user ID

  final List<String> vibes = ['All', 'Chill', 'Techno', 'Game Night', 'BYOB'];

  @override
  void initState() {
    super.initState();
    _fetchParties();
  }

  Future<void> _fetchParties() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedParties = await apiService.getParties(
        userLat,
        userLng,
        vibe: selectedVibe == 'All' ? null : selectedVibe,
      );
      setState(() {
        parties = fetchedParties;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading parties: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('District - House Parties', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildVibeFilters(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : parties.isEmpty
                    ? Center(child: Text('No parties found nearby.'))
                    : ListView.builder(
                        itemCount: parties.length,
                        itemBuilder: (context, index) {
                          final party = parties[index];
                          return _buildPartyCard(party);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeFilters() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: vibes.length,
        itemBuilder: (context, index) {
          final vibe = vibes[index];
          final isSelected = selectedVibe == vibe || (selectedVibe == null && vibe == 'All');
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChoiceChip(
              label: Text(vibe),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedVibe = vibe;
                });
                _fetchParties();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.purple[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartyCard(Party party) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartyDetailScreen(party: party, userId: currentUserId),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    party.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      party.vibe,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(DateFormat('MMM dd, hh:mm a').format(party.dateTime)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('${party.distanceKm} km away (Secret Location)'),
                ],
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: party.currentGuests / party.maxGuests,
                backgroundColor: Colors.grey[300],
                color: Colors.purple,
              ),
              SizedBox(height: 4),
              Text(
                '${party.currentGuests}/${party.maxGuests} guests joined',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
