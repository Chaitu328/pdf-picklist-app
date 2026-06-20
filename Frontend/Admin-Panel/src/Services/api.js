// src/services/api.js
const API_BASE = "https://pick-list.onrender.com/api";

export async function fetchPicklists(token) {
  const res = await fetch(`${API_BASE}/picklist`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  return res.json();
}