from sqlalchemy import Boolean, Column, Integer, String, Float, DateTime
from database import Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    is_verified = Column(Boolean, default=False)
    # in MVP we skip robust auth for simplicity

class Party(Base):
    __tablename__ = "parties"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    vibe = Column(String, index=True)
    date_time = Column(DateTime, default=datetime.datetime.utcnow)
    location_lat = Column(Float)
    location_lng = Column(Float)
    address = Column(String)  # The secret address
    host_id = Column(Integer) # Mock host relation
    max_guests = Column(Integer)
    current_guests = Column(Integer, default=0)

class Booking(Base):
    __tablename__ = "bookings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer)
    party_id = Column(Integer)
    status = Column(String, default="confirmed")
