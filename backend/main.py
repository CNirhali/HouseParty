from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import math

import models, schemas
from database import engine, get_db

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="HousePartyApp API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Helper function to calculate distance using Haversine formula (mocking PostGIS)
def get_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371  # Radius of the earth in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = (math.sin(dLat / 2) * math.sin(dLat / 2) +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dLon / 2) * math.sin(dLon / 2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = models.User(name=user.name, is_verified=True) # auto-verify for MVP
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.post("/parties/", response_model=schemas.Party)
def create_party(party: schemas.PartyCreate, db: Session = Depends(get_db)):
    db_party = models.Party(**party.dict())
    db.add(db_party)
    db.commit()
    db.refresh(db_party)
    return db_party

@app.get("/parties/", response_model=List[schemas.PartyPublic])
def read_parties(lat: float, lng: float, radius_km: float = 50.0, vibe: str = None, db: Session = Depends(get_db)):
    query = db.query(models.Party)
    if vibe:
        query = query.filter(models.Party.vibe == vibe)
    
    parties = query.all()
    
    # Simple distance filtering for MVP
    nearby_parties = []
    for p in parties:
        distance = get_distance(lat, lng, p.location_lat, p.location_lng)
        if distance <= radius_km:
            p_dict = p.__dict__.copy()
            p_dict['distance_km'] = round(distance, 2)
            nearby_parties.append(p_dict)
            
    # Sort by nearest
    nearby_parties.sort(key=lambda x: x['distance_km'])
    return nearby_parties

@app.post("/bookings/", response_model=schemas.Booking)
def create_booking(booking: schemas.BookingCreate, db: Session = Depends(get_db)):
    party = db.query(models.Party).filter(models.Party.id == booking.party_id).first()
    if not party:
        raise HTTPException(status_code=404, detail="Party not found")
        
    if party.current_guests >= party.max_guests:
        raise HTTPException(status_code=400, detail="Party is full")
        
    # Create booking
    db_booking = models.Booking(**booking.dict())
    db.add(db_booking)
    
    # Increment guests
    party.current_guests += 1
    
    db.commit()
    db.refresh(db_booking)
    return db_booking

@app.get("/bookings/{booking_id}/secret", response_model=schemas.Party)
def get_secret_address(booking_id: int, db: Session = Depends(get_db)):
    booking = db.query(models.Booking).filter(models.Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    party = db.query(models.Party).filter(models.Party.id == booking.party_id).first()
    return party # returns the full party info including the address
