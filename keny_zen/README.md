# Keny-Zen — Mental Wellness Journal App

## Overview

Keny-Zen is a mobile mental wellness journaling application built using Flutter and Firebase. The app provides a private and secure space for users to reflect on their thoughts, track their emotions, and gain meaningful insights into their mental patterns over time.

The design focuses on simplicity, calmness, and clarity, allowing users to journal without distraction while still benefiting from structured mood tracking and intelligent feedback.

---

## Core Functionality

### Secure Authentication
Keny-Zen uses Firebase Authentication to manage user accounts. Each user’s data is fully isolated using UID-based access control, ensuring privacy and secure storage of personal journal entries.

---

### Journal Entry System
Users can create daily journal entries that include:
- Written reflections
- Selected mood state
- Timestamped records

All entries are stored in Firebase Firestore under user-specific collections, ensuring organized and private data handling.

---

### Mood Tracking
Each journal entry is associated with a mood selection such as Calm, Stressed, or Overwhelmed. These mood tags are stored alongside entries and serve as the foundation for analytics and insight generation.

---

### Dashboard
The dashboard provides a quick summary of the user’s activity, including:
- Most recent journal entry
- Total number of entries

This allows users to immediately reflect on their latest emotional state and journaling consistency.

---

### Entries View
Users can browse all previous journal entries in a structured list format. Each entry displays:
- Entry content preview
- Mood indicator with color coding
- Date of entry

This creates an easy-to-navigate history of emotional reflections.

---

### Insights & Analytics
The app includes an analytics layer that processes journal data to generate meaningful summaries:
- Total entries tracked
- Most frequent mood
- Current journaling streak

These insights help users recognize patterns in their behavior and emotional trends.

---

### Trend Detection System (Advanced Implementation)

Keny-Zen analyzes recent journal data to detect short-term emotional trends. Specifically, it evaluates the last 7 days of entries to identify patterns such as:

- Repeated stress-related moods
- Increasing frequency of negative emotions
- Stable or improving mood patterns

Based on this analysis, the app generates rule-based wellness suggestions. For example:
- If stress is detected frequently → suggests taking a break
- If mood is stable → reinforces positive behavior

This feature demonstrates data-driven reasoning applied to user-generated emotional data.

---

### Ethical Wellness Boundary Layer (Advanced Implementation)

The app includes a built-in ethical safeguard system to ensure responsible use:
- Clearly communicates that it does not diagnose or replace professional care
- Provides only supportive, non-clinical suggestions
- Avoids overreaching conclusions about mental health

This ensures the application remains a safe and appropriate tool for reflection rather than medical interpretation.

---

### Image Attachment Support

Users can attach images to their journal entries. The system includes:
- Image picker integration
- Local preview before saving
- Firebase Storage upload logic

This allows users to visually document experiences alongside written reflections.

---

### Notification System Integration

Keny-Zen integrates Firebase Cloud Messaging (FCM) to support personalized reminders. The system retrieves and stores device tokens, enabling future delivery of:
- Journaling reminders
- Wellness prompts

This supports habit-building and consistent engagement.

---

### UI / UX Design

The application uses a calm, minimal design focused on user comfort:
- Blue gradient theme to promote relaxation
- Soft card-based layout for readability
- Mood-based color accents
- Custom Zen-inspired spiral logo
- Clean navigation with low cognitive load

The design choices prioritize emotional ease and accessibility during journaling.

---

## Technical Stack

- Flutter (Dart)
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging (FCM)
- Firebase Storage

---

## Architecture

- Frontend: Flutter UI with state-driven updates
- Backend:
  - Firebase Authentication for identity management
  - Firestore for structured journaling data
  - Storage for media handling
- Data Model:
  - User → Entries (UID scoped)
  - Entry fields:
    - content
    - mood
    - timestamp
    - optional image reference

---

## Summary

Keny-Zen combines structured journaling, mood tracking, and analytical insights into a single cohesive application. It demonstrates full-stack mobile development with secure data handling, user-centered design, and advanced features such as trend detection and ethical wellness boundaries.

The application emphasizes both functionality and responsibility, providing meaningful reflection tools while maintaining user privacy and trust.