import requests
from datetime import datetime

BASE_URL = "http://localhost:8000"

def test_api():
    print("1. Creating a Host User...")
    user_data = {"name": "DJ Snake"}
    r = requests.post(f"{BASE_URL}/users/", json=user_data)
    host = r.json()
    print("Host created:", host)

    print("\n2. Creating a Party...")
    party_data = {
        "title": "Techno Night",
        "vibe": "Techno",
        "date_time": datetime.utcnow().isoformat(),
        "location_lat": 28.7041,
        "location_lng": 77.1025,
        "address": "Secret Underground Bunker 42, Delhi",
        "host_id": host["id"],
        "max_guests": 50
    }
    r = requests.post(f"{BASE_URL}/parties/", json=party_data)
    party = r.json()
    print("Party created:", party)

    print("\n3. Finding Nearby Parties...")
    # Same coordinates so distance should be 0.0
    r = requests.get(f"{BASE_URL}/parties/", params={"lat": 28.7041, "lng": 77.1025})
    parties = r.json()
    print("Nearby Parties:", parties)

    print("\n4. Creating a Guest User and Booking...")
    guest_data = {"name": "Party Goer"}
    guest = requests.post(f"{BASE_URL}/users/", json=guest_data).json()
    
    booking_data = {
        "user_id": guest["id"],
        "party_id": party["id"]
    }
    r = requests.post(f"{BASE_URL}/bookings/", json=booking_data)
    booking = r.json()
    print("Booking confirmed:", booking)

    print("\n5. Revealing Secret Address...")
    r = requests.get(f"{BASE_URL}/bookings/{booking['id']}/secret")
    revealed_party = r.json()
    print("Secret Address Revealed:", revealed_party["address"])

if __name__ == "__main__":
    test_api()
