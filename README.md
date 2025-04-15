# 🚗 Breakpoint: Road Quality & Pothole Detection System

**Passively detect potholes and map road quality using your smartphone's accelerometer.**

---

## Overview

Breakpoint is a system designed to **passively detect potholes and assess road quality** using the accelerometer built into everyday smartphones. As users drive, the application analyzes vibration data in real-time to:

1.  **Classify road segments** by surface condition (e.g., smooth asphalt, rough gravel).
2.  **Automatically identify potholes** based on sudden, characteristic vibration spikes.

This collected data powers a **web-based heatmap visualization**, providing a clear, color-coded overview of real-world road conditions across monitored areas. This serves both drivers seeking smoother routes and infrastructure services needing insight into problematic segments.

Beyond immediate visualization, Breakpoint functions as a **scalable infrastructure tool**. All gathered data is stored for longitudinal analysis and potential integration with:

* Existing navigation applications.
* Road maintenance services for smarter, data-driven repair planning.

In essence, Breakpoint combines real-time driver awareness with crowdsourced infrastructure insights. It's designed to be **lightweight, frictionless, and effective**—turning every participating phone into a mobile road quality sensor and every trip into actionable data.

---

## ✨ Key Features

* **Passive Sensing:** Utilizes the phone's accelerometer, requiring no user interaction during drives.
* **Road Condition Classification:** Categorizes road surfaces based on vibration patterns.
* **Automatic Pothole Detection:** Identifies sharp impacts indicative of potholes.
* **Web-Based Heatmap:** Visualizes collected road quality data geographically.
* **Scalable Architecture:** Designed for handling data from multiple users.

---

## 📸 Screenshots & Visuals

**Web Interface:** Visualizing the collected road quality data.
![Group 7](https://github.com/user-attachments/assets/e2bdbcb2-190c-41d9-bd1e-fe6b35b50723)

**Mobile Application:** The data collection interface on the smartphone.
![Group 6](https://github.com/user-attachments/assets/e92ec440-bc7e-42be-9ac0-3e96633b8aed)

**System Architecture:** Overview of the data flow.
![arch.png](arch.png)

---

## 💻 Technology Stack (Example)

* **Mobile App:** Flutter
* **Backend:** Golang
* **Frontend (Web Map):** NextJS, Mapbox GL JS
* **Database:** PostgreSQL with PostGIS
* **Infrastructure:** Docker, DigitalOcean
