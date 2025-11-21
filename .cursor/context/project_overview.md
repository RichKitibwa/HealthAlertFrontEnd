1. System Summary

The Emergency Health Communication System is a two-repository project:

focus on android development for now 


Frontend Repo (Mobile)

One unified codebase

Role-based access determines which interface is shown:

Village Health Team (VHT)

Ambulance Driver

Clinic Staff

Admin / NGO / OPM

Offline-first, multilingual, low-bandwidth UI

Integrated NFC reader for immunization cards

Backend Repo

Centralized API + real-time event system

Data models, authentication, analytics, notifications

Dispatch engine for emergencies

Offline sync engine

SMS + FCM notification service

GPS/ambulance tracking

The system improves emergency response, communication, immunization tracking, and data reporting in low-resource, refugee, and rural environments.

2. Repository Structure
Frontend Repo (single repo – multiple role UIs)

This repo contains all user-facing interfaces:

VHT Interface

Ambulance Driver Interface

Clinic Staff Dashboard

Admin Dashboard

Role-based routing shows each user only what they are allowed to see.

Tech Stack (recommended):

Flutter

Local encrypted storage

Offline-first sync

NFC integration

Mapbox/OSM maps

i18n for multilingual UI

Backend Repo

A single backend powering all frontend workflows:

REST API + Real-time events

Authentication & authorization (RBAC)

Dispatch engine

Notification system

Database models

Analytics + reporting

Offline-sync queue processor

Tech Stack (recommended):

Node.js / Django / Firebase

PostgreSQL / Firestore / Supabase

FCM + SMS fallback

OAuth2 + JWT

3. System Objectives
Primary Objective

Enable fast, coordinated, reliable emergency communication between VHTs, ambulances, clinics, and administrators.

Specific Objectives

NFC-based immunization tracking

Role-specific dashboards

Offline-first functionality

Low-bandwidth operability

Real-time dispatch engine

Ambulance GPS tracking

Analytics for authorities

Patient history + immunization passport

4. Scope
Frontend Repo

Build one application with four role-based UIs

Modular UI screens per role

Unified design system for low literacy

Offline-first architecture

Local DB + background sync

NFC reading

GPS + mapping

SMS fallback UI

Backend Repo

API endpoints for all system functions

Role-based access control

Sync engine for offline use cases

Real-time case updates

GPS tracking endpoints

Notification engine (FCM + SMS)

Data models for all entities

Admin analytics + audit logs

5. User Personas
Village Health Team (VHT)

Goals: emergency reporting, immunization tracking, communication
Pain Points: no network, high caseload

Ambulance Driver

Goals: receive cases, navigate offline, update progress
Pain Points: large coverage, delays, poor comms

Clinic Staff

Goals: prepare for incoming patients, view cases
Pain Points: limited resources, visibility gaps

Admin / NGOs / OPM

Goals: monitor system performance, analytics
Pain Points: limited oversight, heavy caseload

Community Members

Goals: get care
Pain Points: long delays, low literacy, no phones

6. Core App Features (Two Repo Version)
Frontend Features
VHT UI

Emergency case creation

Attach photo/voice note

GPS (manual override allowed)

One-tap dispatch

NFC immunization scanning

Family messaging templates

Offline operation + sync

SMS fallback alerts

Ambulance Driver UI

Receive emergency requests

Accept/reject with one tap

Step-by-step navigation (offline maps)

Text-to-speech

Status updates (en route, arrived, delivered)

Pre-download operational zones

Clinic Staff UI

Incoming cases dashboard

Patient preview

Triage preparation

Close case

Communication with VHT/ambulance

Admin UI

System monitoring

Case analytics

User management

Audit logs

CSV/PDF export

7. User Journey Flows
Flow 1 – VHT

Dashboard → children + immunization status

NFC scan → read history

Create emergency case

Add details + attachments

Dispatch → ambulance + clinic notified

Track ambulance

Receive updates

Submit reports

Flow 2 – Healthcare Practitioner

View incoming cases

Review patient info

Communicate with field staff

Prepare & log triage

Close case

Review trends

Flow 3 – Ambulance Driver

Receive case details

Accept / reject

Offline-capable routing

Text-to-speech messages

Update statuses

Complete case

8. User Stories (Grouped)
VHT

Create emergency with type, urgency, location

Attach voice/photo

One-tap alerts

Receive ambulance confirmation

Multilingual support

Map of overdue immunizations

SMS alerts when offline

Ambulance Driver

Receive case details

Accept with one tap

Offline navigation

TTS for incoming messages

Update progress

SMS fallback

Clinic Staff

See all active cases

Prepare triage

Mark patient received

Notify VHTs/ambulances

View history

Admin

Monitor entire system

Manage accounts

Audit logs

Analytics dashboard

Export data

9. Technical Architecture
Frontend (Single Repo)

Flutter / React Native

Screens modularized by role

Role-based routing:

/vht/*

/ambulance/*

/clinic/*

/admin/*

Offline-first data layer

Local encrypted storage

Background sync

NFC reader integration

Mapbox/OSM SDK

Backend (Single Repo)

REST APIs for all entities

Dispatch engine

GPS + location endpoints

Real-time notifications

Queue for offline sync

FCM + SMS fallback

RBAC for roles

Audit logs + analytics

10. Data Models (Summary)

User (role, language, permissions)

Case (type, urgency, status, timestamps)

Ambulance (availability, driver)

Child (NFC ID, immunization history)

Location (GPS coordinates)

Notification events

Audit logs

Analytics datasets

11. Offline Strategy
Frontend

Local queue for unsent emergencies

Local cached immunization data

Pre-downloaded maps

SMS fallback when sync fails

Backend

Sync endpoint to pull/push queued updates

Timestamp conflict resolution

Store unsent SMS queue

12. WhatsApp Integration (Optional)

Pros: familiar, fast, low cost
Cons: privacy limits, rigid API, dependency

13. Roadmap
V1

NFC prototype

Emergency reporting

Basic VHT → Ambulance → Clinic flow

V2

Offline sync

Navigation

Role-based dashboards

Messaging

V3

Analytics & admin tools

Incentive program

Chronic disease expansion

14. Success Metrics

Faster emergency response

Fewer communication failures

Higher immunization compliance

System uptime

Data completeness

END OF FILE
