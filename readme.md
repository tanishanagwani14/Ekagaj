# Ekagaj

## Project Overview

Build a modern mobile-first Organization Management Application using Flutter and Firebase.

The application should support two roles only:

- Admin
- Employee

This is a single application where features are shown based on user role.

The app should be modern, scalable, clean, responsive, and production-ready.

---

# Main Features

## Authentication

- Firebase Authentication
- Email & Password Login
- Secure Session Management
- Role-Based Access Control

---

# Roles & Permissions

## Employee

Can:

- Mark attendance
- Create tasks
- Assign tasks
- Update task status
- Chat with team
- Add reminders
- Add client follow-ups
- View own profile

---

## Admin

Can:

- Access all employee features
- Manage employees
- View all attendance
- View analytics
- Manage organization settings
- Monitor tasks & follow-ups

---

# Modules

## 1. Attendance Module

Features:

- Check In
- Check Out
- Attendance History
- Daily/Monthly Attendance
- Timestamp Storage
- GPS Support

Firestore Collection:

```json
attendance
{
  userId,
  checkIn,
  checkOut,
  date,
  status
}
```

---

## 2. Task Management Module

Features:

- Create Task
- Assign Task
- Task Priority
- Due Date
- Task Status
- Completed/Pending Tasks

Firestore Collection:

```json
tasks
{
  title,
  description,
  assignedBy,
  assignedTo,
  priority,
  dueDate,
  status,
  createdAt
}
```

---

## 3. Chat Module

Features:

- Real-time Chat
- Group Chat
- One-to-One Chat
- Read Receipts
- File Sharing

Firestore Collections:

```json
chats
messages
groups
```

---

## 4. Follow-Up Module

Features:

- Add Client
- Add Follow-Up
- Reminder Alerts
- Notes
- Follow-Up Status

Firestore Collection:

```json
followups
{
  clientName,
  followupDate,
  notes,
  status,
  createdBy
}
```

---

## 5. Reminder Module

Features:

- Create Reminder
- Daily Reminder
- Notification Alerts
- Reminder History

Firestore Collection:

```json
reminders
{
  title,
  dateTime,
  createdBy,
  completed
}
```

---

# Tech Stack

## Frontend

- Flutter

## State Management

- Riverpod

## Backend

- Firebase

## Database

- Cloud Firestore

## Authentication

- Firebase Auth

## Notifications

- Firebase Cloud Messaging

## Storage

- Firebase Storage

---

# Architecture

Use clean architecture and feature-first folder structure.

```bash
lib/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── attendance/
│   ├── tasks/
│   ├── chat/
│   ├── followups/
│   ├── reminders/
│   ├── dashboard/
│   ├── profile/
│   └── admin/
│
├── models/
├── providers/
├── routes/
└── main.dart
```

---

# UI Requirements

The UI should be:

- Modern
- Minimal
- Professional
- Fast
- Responsive
- Mobile-first
- Productivity-focused

Use:

- Rounded corners
- Soft shadows
- Card-based layout
- Smooth spacing
- Modern typography
- Gradient primary colors

Design inspiration:

- Slack
- Notion
- ClickUp
- Trello
- Linear

---

# App Screens

## Authentication

- Splash Screen
- Login Screen

## Main Screens

- Dashboard
- Attendance
- Tasks
- Chat
- Follow-Ups
- Reminders
- Notifications
- Profile

## Admin Screens

- Employee Management
- Analytics Dashboard
- Organization Settings

---

# Navigation

Use Bottom Navigation Bar:

```bash
Home | Tasks | Chat | Attendance | Profile
```

Admin gets additional menu options.

---

# Required Flutter Packages

```yaml
firebase_core:
firebase_auth:
cloud_firestore:
firebase_storage:
firebase_messaging:
flutter_riverpod:
go_router:
intl:
image_picker:
cached_network_image:
flutter_screenutil:
```

---

# Development Rules

- Use reusable widgets
- Keep UI components modular
- Follow clean architecture
- Use proper naming conventions
- Use Riverpod for state management
- Separate business logic from UI
- Optimize Firestore queries
- Write scalable code
- Keep code production-ready

---

# Firebase Requirements

Enable:

- Authentication
- Firestore Database
- Firebase Storage
- Firebase Cloud Messaging

---

# Security Rules

- Users can only edit their own data
- Role-based Firestore access
- Admin-only analytics access
- Secure authenticated APIs

---

# MVP Goal

Build a stable production-ready MVP with:

- Authentication
- Attendance
- Tasks
- Chat
- Follow-Ups
- Reminders
- Role Management

---

# Future Scope

Future upgrades:

- Leave Management
- Payroll
- AI Assistant
- Video Calling
- CRM Dashboard
- Advanced Analytics

---

# Important Notes

- Keep the app lightweight and fast
- Focus on usability
- Prioritize mobile UX
- Avoid unnecessary complexity
- Maintain clean code structure
- Build scalable Firestore collections
- Use reusable UI components everywhere

---

# Output Expectation

Generate:

- Production-ready Flutter code
- Responsive UI
- Firebase integration
- Scalable architecture
- Modern SaaS-quality design
- Clean modular codebase

