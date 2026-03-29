from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    name: str

class UserCreate(UserBase):
    pass

class User(UserBase):
    id: int
    is_verified: bool

    class Config:
        from_attributes = True

class PartyBase(BaseModel):
    title: str
    vibe: str
    date_time: datetime
    location_lat: float
    location_lng: float
    address: str
    host_id: int
    max_guests: int

class PartyCreate(PartyBase):
    pass

class Party(PartyBase):
    id: int
    current_guests: int

    class Config:
        from_attributes = True

class PartyPublic(BaseModel):
    id: int
    title: str
    vibe: str
    date_time: datetime
    location_lat: float
    location_lng: float
    host_id: int
    max_guests: int
    current_guests: int
    distance_km: Optional[float] = None # Added via computation

    class Config:
        from_attributes = True

class BookingCreate(BaseModel):
    user_id: int
    party_id: int

class Booking(BookingCreate):
    id: int
    status: str

    class Config:
        from_attributes = True
