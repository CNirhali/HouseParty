const API_BASE = "http://localhost:8000";
const USER_LAT = 28.7041;
const USER_LNG = 77.1025;
const USER_ID = 2; // Fixed mock user

let selectedVibe = "All";
let partiesCache = [];
let currentParty = null;

// DOM Elements
const feedScreen = document.getElementById("feed-screen");
const detailScreen = document.getElementById("detail-screen");
const vibeFiltersContainer = document.getElementById("vibe-filters");
const partyListContainer = document.getElementById("party-list");

// Detail Elements
const detailTitle = document.getElementById("detail-title");
const detailVibe = document.getElementById("detail-vibe");
const detailDate = document.getElementById("detail-date");
const detailLocation = document.getElementById("detail-location");
const detailGuests = document.getElementById("detail-guests");
const bookBtn = document.getElementById("book-btn");
const successMsg = document.getElementById("success-msg");

const vibes = ["All", "Chill", "Techno", "Game Night", "BYOB"];

// Initialize
function init() {
    renderFilters();
    fetchParties();

    document.getElementById("back-btn").addEventListener("click", () => {
        detailScreen.classList.remove("active");
        feedScreen.classList.add("active");
        fetchParties(); // Refresh list to show guest count increment
    });

    bookBtn.addEventListener("click", bookParty);
}

function renderFilters() {
    vibeFiltersContainer.innerHTML = "";
    vibes.forEach(vibe => {
        const chip = document.createElement("div");
        chip.className = `vibe-chip ${vibe === selectedVibe ? "active" : ""}`;
        chip.textContent = vibe;
        chip.onclick = () => {
            selectedVibe = vibe;
            renderFilters();
            fetchParties();
        };
        vibeFiltersContainer.appendChild(chip);
    });
}

async function fetchParties() {
    try {
        let url = `${API_BASE}/parties/?lat=${USER_LAT}&lng=${USER_LNG}`;
        if (selectedVibe !== "All") url += `&vibe=${selectedVibe}`;
        
        const res = await fetch(url);
        partiesCache = await res.json();
        renderParties();
    } catch (e) {
        partyListContainer.innerHTML = `<p>Error loading parties. Ensure backend is running.</p>`;
    }
}

function renderParties() {
    partyListContainer.innerHTML = "";
    if (partiesCache.length === 0) {
        partyListContainer.innerHTML = "<p style='padding:20px'>No parties nearby with this vibe.</p>";
        return;
    }

    partiesCache.forEach(party => {
        const card = document.createElement("div");
        card.className = "party-card";
        
        const progress = (party.current_guests / party.max_guests) * 100;

        card.innerHTML = `
            <div class="card-header">
                <div class="card-title">${party.title}</div>
                <div class="card-vibe">${party.vibe}</div>
            </div>
            <div class="card-info">
                📅 ${new Date(party.date_time).toLocaleString()}<br>
                📍 ${party.distance_km} km away (Secret Location)
            </div>
            <div class="progress-bar-bg">
                <div class="progress-bar-fill" style="width: ${progress}%"></div>
            </div>
            <div class="progress-text">${party.current_guests}/${party.max_guests} guests joined</div>
        `;
        
        card.onclick = () => openDetail(party);
        partyListContainer.appendChild(card);
    });
}

function openDetail(party) {
    currentParty = party;
    feedScreen.classList.remove("active");
    detailScreen.classList.add("active");

    detailTitle.textContent = party.title;
    detailVibe.textContent = party.vibe;
    detailDate.textContent = new Date(party.date_time).toLocaleString();
    detailLocation.textContent = "Address locked. Book to unlock.";
    detailLocation.style.color = "grey";
    detailGuests.textContent = `${party.current_guests}/${party.max_guests} Guests Verified`;
    
    bookBtn.disabled = false;
    bookBtn.style.display = "block";
    successMsg.classList.add("hidden");
}

async function bookParty() {
    bookBtn.disabled = true;
    bookBtn.textContent = "Processing Verification...";

    try {
        const res = await fetch(`${API_BASE}/bookings/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ user_id: USER_ID, party_id: currentParty.id })
        });
        
        if (res.ok) {
            const booking = await res.json();
            bookBtn.style.display = "none";
            successMsg.classList.remove("hidden");
            revealAddress(booking.id);
        } else {
            alert("Booking failed. Party might be full.");
            bookBtn.disabled = false;
            bookBtn.textContent = "Request to Join (Digital Doorbell)";
        }
    } catch (e) {
        alert("Network error.");
        bookBtn.disabled = false;
        bookBtn.textContent = "Request to Join (Digital Doorbell)";
    }
}

async function revealAddress(bookingId) {
    try {
        const res = await fetch(`${API_BASE}/bookings/${bookingId}/secret`);
        if (res.ok) {
            const data = await res.json();
            detailLocation.textContent = data.address;
            detailLocation.style.color = "black";
            detailLocation.style.fontWeight = "bold";
        }
    } catch {
        // error resolving secret location
    }
}

// Start
init();
