# PRD – Dikkha AI

## 0. Document Info

- Product Name: Dikkha AI
- Platform: Android (Flutter, Material 3, mobile only in v1)
- Primary Audience: Class 9-10 students in Bangladesh
- Author: Nafis Radoan
- Version: v0.1
- Last Updated: 25 Nov 2025

---

## 1. Product Overview

An Android app (built with Flutter) that helps Bangladeshi Class 9-10 students learn from NCTB-aligned textbooks and practice concepts using an AI tutor.

Core pillars:

1. Structured Learning: Read syllabus-aligned books in a clean, focused Markdown reader with chapter navigation and math (LaTeX/KaTeX) support.
2. Adaptive Help: Ask AI questions about any selected text or subject (Explain, Solve, Clarify, etc.).
3. Simple Onboarding: Phone-number-based login (Firebase in future), minimal profile setup (name, class, group, board).
4. Delightful but Minimal UI: “Intelligent Simplicity” with a clean light theme based on given brand colors and Material 3.

---

## 2. Goals & Non-goals

### 2.1 Goals

- Make accessing Class 9–10 textbooks easy and friendly on mobile.
- Help students understand, not just read – via AI explanations, step-by-step solutions, and Q&A.
- Provide a frictionless onboarding: mobile number → OTP → basic profile.
- Make the UI simple, lightweight and optimized for reading long Bangla + English content.
- Enable continuous learning with chat history and context-aware AI help.

### 2.2 Non-goals (v1)

- No teacher/parent dashboards.
- No in-app payments or subscriptions.
- No complex gamification (points, badges, leaderboards) in v1.
- No admin content management panel (content will be managed externally and bundled/synced).

---

## 3. Target Users & Use Cases

### 3.1 Primary Users

Class 9–10 Students in Bangladesh  
- Boards: e.g., Dhaka, Chittagong, etc. (Board will be a selectable field).  
- Groups: Science, Commerce, Humanities (configurable).

### 3.2 Example Use Cases

- A Class 10 science student reading Physics Chapter 3 and asking AI to explain a formula.
- A Class 9 humanities student stuck on a paragraph in Bangla literature, selecting the text and tapping “Explain it”.
- Student revisits the AI chat history to review explanations before exams.
- Student edits profile when they move from Class 9 to Class 10.

---

## 4. High-level User Flows

### 4.1 Onboarding & Auth Flow

1. Splash Screen
   - Shows app logo/name on brand background.
   - Auto-transitions to Get Started screen after short delay.

2. Get Started Screen
   - Background: #FDFAF5 (Creamy White).
   - Simple educational animation (Lottie or similar).
   - CTA button: “Get Started” (Primary, #6C63FF).
   - On tap → Mobile Number Screen.

3. Mobile Number Screen
   - Title: “Enter your mobile number”.
   - Input: Phone number with BD country code suggestion.
   - Primary button: “Continue” → triggers simulated OTP call (Phase 1).
   - For now: No Firebase integration; we simulate OTP send.
   - On success: navigate to OTP Verification Screen.

4. OTP Verification Screen
   - Input fields for 6-digit OTP.
   - Primary button: “Verify”.
   - For now: Simulate success if code matches a dummy pattern (e.g., 123456).
   - If existing user profile found (local db / mock):
     - Go directly to Main Screen.
   - Else:
     - Go to Create Profile Screen.

5. Create Profile Screen
   - Fields:
     - Full Name (text).
     - Class/Grade (dropdown: Class 9, Class 10).
     - Group (dropdown: Science, Commerce, Humanities, Other).
     - Board (dropdown: major BD boards; list can be hardcoded in v1).
   - Primary button: “Save & Continue” → creates local user profile (and later synced with backend).
   - Navigate to Main Screen.

### 4.2 Main Navigation

- Top App Bar:
  - App title / logo on left.
  - User Avatar (circle) on right.
    - Tap opens Profile Action Sheet:
      - Name (non-editable text for quick view).
      - Buttons:
        - “Profile”
        - “Logout”

- Bottom Navigation Bar (Material 3):
  1. Read Book (default selected)
  2. AI Chatbot

### 4.3 Read Book Flow

1. Subject Selection
   - At top: horizontally scrollable chips for subjects based on Grade & Group.
     - Example: Bangla, English, Math, Physics, Chemistry, Biology, ICT, etc.
   - On chip tap: load relevant Book Reader Screen.

2. Chapter Navigation
   - Under subject title or as a secondary scrollable chip row.
   - Each chip = chapter title/number.
   - Tap to jump directly to that chapter’s section inside the Markdown.

3. Book Reader
   - Background: #FDFAF5 (Creamy White).
   - Book content: Markdown rendered as:
     - Text: #2D2D3D (Deep Slate).
     - Support headings, lists, bold, italics, code, images.
     - LaTeX/KaTeX support: inline & block equations.
   - Text selection:
     - When user selects any text:
       - Highlight color: #EEEBFF (Lavender Mist).
       - Automatically trigger a Bottom Sheet:
         - Shows selected text preview.
         - Quick actions (buttons):
           - “Explain it”
           - “Solve it” (for equations/problems)
         - Custom prompt input box:
           - Placeholder: “Ask anything about this selection…”
           - Send icon to send prompt.
       - On send:
         - Open AI area (either inline or navigate to AI Chat tab with pre-filled context).
         - Show AI answer.

4. Persisting Reading State
   - Remember last subject & chapter read.
   - Optional v1: scroll position per chapter (nice to have).

### 4.4 AI Chatbot Flow

1. Subject Context Selector
   - At top of AI screen:
     - Chip or dropdown for Subject (same list as Read Book).
     - Selection sets the context for AI responses.

2. Chat Interface
   - Background: #FDFAF5.
   - Message bubbles:
     - AI Messages:
       - Background: #FFFFFF (Pure White).
       - Border: thin #EEEBFF or subtle shadow.
       - Text: #2D2D3D.
       - May contain LaTeX/KaTeX rendered equations & markdown (lists, bold, etc.).
     - User Messages:
       - Background: #EEEBFF (Lavender Mist).
       - Text: #2D2D3D.

3. Input Area
   - Text field with rounded corners.
   - Icons:
     - Mic → voice input (speech-to-text; can be stubbed v1).
     - Camera → capture photo.
     - Attachment → pick image from gallery.
   - When image is attached, show thumbnail above text area.
   - Send button: primary icon (Paper plane) tinted with #6C63FF.

4. History View
   - Entry point: icon or button for “History” in top-right of AI screen.
   - Shows a list of past sessions:
     - Each item: Subject, short snippet or time, date.
     - On tap: open full chat thread.
     - Each history item has:
       - Delete icon (trash) to remove that session.
   - Option: “Clear all history” (with confirmation dialog).

5. Image & Voice Handling (v1)
   - Voice: convert speech to text and insert into input (can use platform STT).
   - Image: send image along with prompt metadata to backend (actual AI understanding may be stubbed / TBD).

### 4.5 Profile & Logout Flow

- Avatar → Sheet
  - Name (text), plus:
    - “Profile”
    - “Logout”

- Profile Screen
  - Shows:
    - Name (editable).
    - Mobile number (non-editable or partially masked).
    - Grade (editable).
    - Group (editable).
    - Board (editable).
  - Button: “Save Changes”.
  - Optional: “Change avatar” (photo pick).

- Logout
  - Show a confirmation dialog:
    - “Are you sure you want to logout?”
    - Buttons: Cancel (secondary), Logout (primary).
  - On confirm:
    - Clear auth tokens / local user data (except maybe content cache).
    - Navigate back to Mobile Number Screen or Get Started (defined in dev).

---

## 5. Detailed Feature Requirements

### 5.1 Authentication & User Management

FR-1: App should allow login via Bangladeshi mobile phone number.  
FR-2: OTP verification flow with 6-digit code.

- Phase 1:
  - Mock OTP send and verify.
- Phase 2 (Integration):
  - Firebase Phone Auth:
    - Send OTP using Firebase.
    - Handle verification, errors, resends, etc.

FR-3: If user has a saved profile associated with phone:
- Skip profile creation and go to Main Screen.

FR-4: If user does not have a profile:
- Show Create Profile screen and require fields.

FR-5: Save user profile locally (SQLite / Hive) and optionally sync with backend in future.

---

### 5.2 Book Reader & Markdown Engine

FR-6: Books are stored as Markdown files bundled within the app (v1) or fetched from backend (future).  
FR-7: Build a Markdown renderer in Flutter that supports:

- Heading levels (H1–H4).
- Ordered/unordered lists.
- Bold, italics, inline code.
- Blockquotes.
- Inline images and diagrams (if present).
- LaTeX/KaTeX:
  - Inline: $...$
  - Block: $$...$$

FR-8: The reader must apply the brand styles:

- Background: #FDFAF5.
- Text: #2D2D3D.
- Selected text: highlight with #EEEBFF.

FR-9: Implement chapter navigation via chips:

- Each subject → list of chapters.
- Tap chip → jump to that chapter.

FR-10: Text selection to AI:

- When user selects text:
  - Show system highlight.
  - Trigger bottom sheet automatically (no extra tap).
  - Bottom sheet components:
    - Selected text snippet (truncated if long).
    - Suggested prompts:
      - “Explain it”
      - “Solve it”
    - Custom prompt text field + send button.
- On sending:
  - Open AI Chat context:
    - Pass selected text + selected prompt as context.
    - Show AI reply.

---

### 5.3 AI Chatbot

FR-11: Chat interface with conversation threads.  
FR-12: Subject selection at top: mandatory context for each conversation.  
FR-13: Each message:

- Stores:
  - Role (user/AI).
  - Subject.
  - Timestamp.
  - Text.
  - (Optional) attached image metadata.

FR-14: History:

- Each chat session represented as:
  - id, subject, title/summary, createdAt, updatedAt.
- List view:
  - Sort by updatedAt desc.
- Delete:
  - Remove selected session with confirmation.

FR-15: AI Backend Integration (TBD):

- Single REST endpoint for:
  - text-only Q&A,
  - text + image Q&A,
  - context from selected text.
- Must support markdown + LaTeX/KaTeX in AI responses.

FR-16: Support for attachments:

- Camera:
  - Capture image for a question.
- Gallery:
  - Choose existing image.

FR-17: Voice:

- Convert speech to text.
- Filled into message input (user can edit before sending).

---

### 5.4 Profile Management

FR-18: Profile screen for viewing & editing user data.  
FR-19: Editable: Name, Grade, Group, Board.  
FR-20: Read-only: Phone number.  
FR-21: Persist changes locally and (future) sync to backend.

---

### 5.5 Logout

FR-22: Log out clears current session & profile from memory/cached auth.

- Optionally keep downloaded book content.

FR-23: After logout, user is returned to an appropriate start screen (likely phone number screen).

---

## 6. UI & Visual Design Requirements

### 6.1 Color System

Use brand colors:

- Primary Brand – Royal Violet: #6C63FF
- Pressed State – Deep Violet: #5A52D5
- On Primary Text: #FFFFFF
- App Background – Creamy White: #FDFAF5
- Card Surface – Pure White: #FFFFFF
- Highlight Surface – Lavender Mist: #EEEBFF
- Primary Text – Deep Slate: #2D2D3D
- Secondary Text – Soft Grey: #787885
- Divider – Pale Grey: #E0E0E0

Application:

- Splash / primary CTAs / active nav icon: #6C63FF.
- Pressed states: #5A52D5.
- Screens background: #FDFAF5.
- Cards & bubbles: #FFFFFF or #EEEBFF.

### 6.2 Material 3

Use Material 3 components and theming across the app:

- NavigationBar for bottom navigation.
- FilledButton for primary actions.
- OutlinedButton / TextButton for secondary actions.
- NavigationDrawer is not needed in v1.

### 6.3 Typography

- Systemwide base: Roboto (for English).
- Bangla font: choose a high-quality Bangla font that renders clearly (e.g., Hind Siliguri via Google Fonts or Noto Sans Bengali).
- Use proper fallback chain: Roboto + Bangla font.
- Styles:
  - AppBar / Headings: Medium–Semibold.
  - Body text: Regular.
  - Support both Bangla and English seamlessly in same paragraphs.

### 6.4 Layout & Interaction

- Minimalistic layouts with generous padding.
- Rounded corners (8–16dp) for cards, bubbles, bottom sheets.
- Smooth transitions between screens (Fade/Slide).
- Bottom sheet for text selection: half-screen height, scrollable if needed.

### 6.5 Figma Reference

- Use provided Figma screens (links TBD) as the source of truth for layout details.
- Any deviation should be explicitly discussed & documented.

---

## 7. Technical Requirements

### 7.1 Tech Stack

- Framework: Flutter (latest stable).
- Language: Dart.
- Platform: Android (min SDK version TBD; recommended 21+).
- Architecture:
  - State management: Riverpod / Bloc / Provider (TBD).
  - Clean architecture recommended, layers:
    - Presentation (UI),
    - Domain (use cases),
    - Data (repositories, local storage, remote APIs).

- Backend Services:
  - Phase 1:
    - Local mock services (for OTP & AI).
  - Phase 2:
    - Firebase:
      - Auth (phone).
      - Firestore / Realtime DB (for user & history).
    - AI API (OpenAI/other) via HTTP.

- Storage:
  - Local DB (Hive/Drift/Sqflite) for:
    - Books (if offline).
    - AI chat history.
    - User profile.

### 7.2 Markdown & LaTeX/KaTeX

- Use a Flutter Markdown engine with:
  - Custom builders for LaTeX blocks:
    - Plug in flutter_math_fork or similar for KaTeX-like rendering.
- Ensure consistent fonts & sizes between reader and AI chat.

### 7.3 Performance

- Book screen must load in under 2 seconds for locally cached content.
- Lazy loading long chapters to avoid jank.
- Image compression for uploads.

### 7.4 Analytics (Future Optional)

- Track:
  - Time spent reading per subject.
  - AI questions asked per subject.
- No personal sensitive data in analytics.

### 7.5 Security & Privacy

- All API calls over HTTPS.
- Minimal PII: name, phone, grade, group, board only.
- Store phone securely (encrypted local storage recommended if possible).

---

## 8. Information Architecture

### 8.1 Screens List

1. Splash
2. Get Started
3. Mobile Number
4. OTP Verification
5. Profile Creation
6. Main (Bottom Nav Container)
   - Read Book
     - Subject & Chapter selection area
     - Reader
   - AI Chat
     - Chat list, history
7. Profile
8. Chat History list
9. (Optional) Individual Chat Full-Screen view

---

## 9. Data Model (Draft)

### 9.1 User

Example shape:

- id: string
- phone: string
- name: string
- grade: "9" or "10"
- group: "Science" | "Commerce" | "Humanities" | "Other"
- board: e.g. "Dhaka" | "Chittagong" | "..."
- createdAt: timestamp
- updatedAt: timestamp

### 9.2 Book / Chapter

Example shape:

- id: string
- subject: e.g. "Physics"
- grade: "9"
- group: "Science"
- title: "Physics Book Class 9"
- chapters: array of:
  - id: string
  - chapterNumber: int
  - title: string
  - markdownPath: e.g. "assets/books/physics_9/ch1.md"

### 9.3 Chat Session

Example shape:

- id: string
- userId: string
- subject: e.g. "Physics"
- title: e.g. "Motion doubts"
- createdAt: timestamp
- updatedAt: timestamp

### 9.4 Chat Message

Example shape:

- id: string
- sessionId: string
- role: "user" or "ai"
- content: string (markdown + LaTeX)
- imagePath: string or null
- createdAt: timestamp

---

## 10. Testing & Acceptance Criteria (High-level)

- User can:
  - Install app and reach Get Started.
  - Enter phone, verify OTP (mock), create profile.
  - Reopen app and get auto-logged into Main screen (if profile exists).

- Read Book:
  - Select subject and chapter.
  - Scroll through Markdown correctly rendered in Bangla + English.
  - See equations rendered properly (LaTeX).
  - Select text, bottom sheet appears with correct selected text.
  - Use “Explain it” → AI response received and displayed.

- AI Chat:
  - Can change subject context.
  - Send text-only question, get AI answer (mock or real backend).
  - Attach a photo and send (even if AI mock).
  - Use voice-to-text input.
  - See history list, open and delete sessions.

- Profile:
  - Edit personal info and see changes reflected.

- Design:
  - Colors match brand guidelines.
  - Buttons, app bars, navigation follow Material 3.
  - Backgrounds, text colors and selection states align with the brand spec.

---