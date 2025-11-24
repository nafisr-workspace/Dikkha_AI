# AGENTS – Dikkha AI

This document defines the key **agents/roles** responsible for building and maintaining the app described in `PRD.md`.  
Each agent can be a human, an AI assistant, or a combination of both, as long as the responsibilities are covered.

---

## 0. Global Conventions

- **Primary Source of Truth:** `PRD.md`  
- **Platform:** Flutter (Android, Material 3)  
- **Domain:** Education (Bangladesh, Class 9–10)  
- **Core Features:** Phone auth, profile, Markdown book reader with LaTeX, subject-based AI chatbot, chat history.

All agents must:
- Respect the **brand identity & color system** described in the PRD.
- Optimize for **Bangla + English** content, especially in the reader and chat.
- Keep the experience consistent with **Material 3** and “Intelligent Simplicity”.

---

## 1. PRODUCT_OWNER_AGENT

### Purpose
Owns the product vision, scope, priorities, and alignment between `PRD.md` and actual implementation.

### Responsibilities
- Maintain and evolve `PRD.md` (features, flows, constraints, open questions).
- Clarify business rules (e.g., what happens on logout, default landing after OTP, etc.).
- Prioritize features for releases (MVP vs future).
- Approve/reject major UX or technical changes that affect scope.

### Inputs
- Market understanding (Bangladeshi Class 9–10 students, boards, etc.).
- Stakeholder feedback (students, teachers, founders).
- Analytics and user feedback (when available).

### Outputs
- Updated `PRD.md` and release roadmaps.
- Clear acceptance criteria and success metrics.
- Prioritized feature backlog.

### Collaborates With
- UX_UI_AGENT (for UX trade-offs).
- FLUTTER_APP_ARCHITECT_AGENT (for feasibility).
- AI_ORCHESTRATION_AGENT (for AI-related limitations and capabilities).

### Out of Scope
- Direct implementation details (e.g., which package to use) unless it affects product vision or major constraints.

---

## 2. UX_UI_AGENT

### Purpose
Translate the product definition and brand guidelines into a coherent, usable and delightful UI/UX, aligned with Material 3 and the given color system.

### Responsibilities
- Own and refine Figma designs for:
  - Splash, Get Started, Phone & OTP screens.
  - Profile creation/edit.
  - Main screen, bottom navigation, avatar menu.
  - Book reader (subject chips, chapter chips, text selection bottom sheet).
  - AI chat (subject selector, chat bubbles, history view).
- Apply the brand **color palette**, **typography**, and **spacing** exactly as specified.
- Define component states (pressed, disabled, error).
- Produce design specs for developers (spacing, font sizes, iconography).

### Inputs
- `PRD.md`
- Brand color and typography guidelines.
- Figma files (existing basic frames).

### Outputs
- Final Figma flows for all screens.
- Component library (buttons, chips, text fields, cards, bubbles, etc.).
- UX documentation (how text selection bottom sheet appears, transitions, etc.).

### Collaborates With
- FLUTTER_APP_ARCHITECT_AGENT (for feasibility and adaptation to Flutter widgets).
- FLUTTER_FRONTEND_AGENT (for pixel-perfect implementation).
- PRODUCT_OWNER_AGENT (for scope vs UX complexity).

### Out of Scope
- Choosing backend architecture.
- Defining AI prompts or context window logic.

---

## 3. FLUTTER_APP_ARCHITECT_AGENT

### Purpose
Define the **overall app architecture** in Flutter, ensuring scalability, testability, and clear separation of concerns.

### Responsibilities
- Choose state management (e.g., Riverpod / Bloc / Provider) and justify it.
- Define project structure:
  - `lib/app` (entry, routing, themes)
  - `lib/features/auth`, `lib/features/reader`, `lib/features/chat`, `lib/features/profile`, etc.
- Design navigation flow:
  - Splash → Get Started → Phone → OTP → Profile → Main (Bottom Nav).
- Define data models and repositories for:
  - User, Book, Chapter, Chat Session, Chat Message.
- Setup **theming**:
  - Material 3 theme using brand colors.
  - Global typography (Roboto + Bangla fallback).
- Decide integration boundary for:
  - Markdown renderer + LaTeX engine.
  - Local DB (Hive/Drift/Sqflite).
  - Firebase & AI APIs (abstracted via repositories/use cases).

### Inputs
- `PRD.md`
- UX_UI_AGENT specs.
- Constraints from BACKEND_API_AGENT & AI_ORCHESTRATION_AGENT.

### Outputs
- Architecture diagram(s).
- High-level code skeleton (folders, main.dart, routing structure).
- Shared interfaces / abstract classes for repositories & services.

### Collaborates With
- FLUTTER_FRONTEND_AGENT (implementation details).
- BACKEND_API_AGENT (contracts).
- AI_ORCHESTRATION_AGENT (how AI calls are made / encapsulated).

### Out of Scope
- Writing every single widget’s layout (delegated to FLUTTER_FRONTEND_AGENT).
- Final visual tweaks (owned by UX_UI_AGENT + FLUTTER_FRONTEND_AGENT).

---

## 4. FLUTTER_FRONTEND_AGENT

### Purpose
Implement all **screens and UI logic** in Flutter, following the architecture and design specifications.

### Responsibilities
- Implement all UI screens:
  - Splash & Get Started.
  - Phone input & OTP verification.
  - Profile creation & edit.
  - Main screen with bottom navigation (Read Book, AI Chat).
  - Book reader with subject & chapter chips, Markdown view, text selection, bottom sheet.
  - AI chat with subject filter, messages, input bar, image/voice actions, history view.
- Integrate theming and typography usage.
- Implement text selection hook in the reader to trigger bottom sheet and send context to AI.
- Implement chat bubble layouts, history list, and deletion flow.
- Ensure **Material 3** components and interactions feel native and polished.

### Inputs
- `PRD.md`
- Figma from UX_UI_AGENT.
- Architecture guidelines from FLUTTER_APP_ARCHITECT_AGENT.
- Domain models & repository interfaces.

### Outputs
- Production-grade Flutter UI code.
- UI unit/widget tests where appropriate.
- Demo builds for review.

### Collaborates With
- UX_UI_AGENT (pixel-perfect alignment).
- FLUTTER_APP_ARCHITECT_AGENT (architecture).
- BACKEND_API_AGENT (binding data to UI).
- CONTENT_BOOK_AGENT (for sample books/assets to test reader).

### Out of Scope
- Backend endpoints definition.
- Deciding AI prompt structures or business logic of AI responses.

---

## 5. BACKEND_API_AGENT

### Purpose
Design and (if needed) implement the backend APIs powering auth (beyond Firebase), AI communication, and content services.

### Responsibilities
- Define REST (or GraphQL) API contracts for:
  - AI chat endpoint(s): text-only, text + image, selected-text context.
  - Syncing user profile and chat history (if backend-managed).
- Decide how to interface with:
  - Firebase Phone Auth (for server-side verification if required).
  - AI provider (OpenAI, etc.).
- Ensure APIs support **markdown + LaTeX** in responses.
- Set up security best practices (HTTPS, auth tokens, rate limits).
- Provide mock endpoints / Postman collections / OpenAPI specs for Flutter devs.

### Inputs
- `PRD.md`
- Requirements from AI_ORCHESTRATION_AGENT.
- Scale & cost constraints from PRODUCT_OWNER_AGENT.

### Outputs
- API specs (OpenAPI/Swagger).
- Implementation (if in scope).
- Environment & configuration info for Flutter app.

### Collaborates With
- FLUTTER_APP_ARCHITECT_AGENT (integration layer).
- AI_ORCHESTRATION_AGENT (payload formats, prompts).
- QA_AGENT (for API tests).

### Out of Scope
- UI or Flutter widget coding.
- Detailed front-end state management.

---

## 6. CONTENT_BOOK_AGENT

### Purpose
Manage and validate all **textbook content**: Markdown files, chapter structure, LaTeX correctness, and asset organization.

### Responsibilities
- Prepare and organize Markdown book files:
  - `assets/books/{grade}/{subject}/chX.md`.
- Ensure markdown structure:
  - Headings for chapters & sections.
  - Proper lists, emphasis, tables (if any).
- Validate **LaTeX blocks**:
  - Syntactically correct.
  - Render well with selected Flutter math package.
- Maintain mapping:
  - Grade → Group → Subject → Chapters → Markdown paths.
- Provide demo content for development & testing (Physics, Math, Bangla, etc.).

### Inputs
- NCTB or official syllabus content (out of app scope, but used here).
- PRD requirements for markdown & LaTeX.

### Outputs
- Organized content tree under `assets/`.
- JSON or Dart configuration mapping content metadata (subjects, chapters).
- Documentation for how to add/update content.

### Collaborates With
- FLUTTER_FRONTEND_AGENT (for reader testing).
- FLUTTER_APP_ARCHITECT_AGENT (for content loading strategy).
- QA_AGENT (to verify rendering).

### Out of Scope
- AI prompts or reasoning about the content (that belongs to AI_ORCHESTRATION_AGENT).

---

## 7. AI_ORCHESTRATION_AGENT

### Purpose
Design how the app interacts with AI: prompt templates, subject context injection, safety constraints, and handling of images & LaTeX.

### Responsibilities
- Define prompt templates for:
  - “Explain it” (selected text).
  - “Solve it” (math or physics problems).
  - General subject Q&A.
- Ensure AI always:
  - Knows the **subject**, **grade**, and **context** (selected text if relevant).
  - Responds in clear Bangla and/or English, according to the question.
  - Uses **markdown + LaTeX** for structured answers and equations.
- Define structure of requests & responses:
  - How to send images (uploaded URLs, base64, etc.).
  - Maximum context length.
- Set guardrails for safe & exam-focused responses (no irrelevant content).
- Work with BACKEND_API_AGENT to choose AI provider and parameters (temperature, max tokens, etc.).

### Inputs
- `PRD.md`
- Subject + chapter metadata from CONTENT_BOOK_AGENT.
- Constraints from BACKEND_API_AGENT.

### Outputs
- Prompt libraries and guidelines.
- Request/response JSON schemas.
- Documentation for how front-end should call AI endpoints.

### Collaborates With
- BACKEND_API_AGENT (API design, reliability).
- FLUTTER_FRONTEND_AGENT (how to display AI responses).
- QA_AGENT (edge cases: mis-answers, failed calls).

### Out of Scope
- Implementing UI layers or theming.
- Deciding product scope (owned by PRODUCT_OWNER_AGENT).

---

## 8. QA_AGENT

### Purpose
Ensure the app behavior matches `PRD.md`, is stable, and provides a good user experience on target devices.

### Responsibilities
- Create **test plans** aligned with PRD sections:
  - Onboarding/auth.
  - Profile.
  - Reader & chapter navigation.
  - Text selection & AI bottom sheet.
  - AI chat, history, deletion.
  - Logout flow.
- Write test cases for:
  - Different grades, groups, boards.
  - Long chapters, heavy LaTeX.
  - Poor network conditions for AI calls.
- Execute manual testing on multiple Android devices / emulators.
- Coordinate with devs on bug reports and verify fixes.
- (Optional) Define automation scope: widget tests, integration tests, API tests.

### Inputs
- `PRD.md`
- Builds from FLUTTER_FRONTEND_AGENT.
- API specs from BACKEND_API_AGENT.

### Outputs
- Test plans and checklists.
- Bug reports (with clear repro steps).
- Regression test runs before releases.

### Collaborates With
- All technical agents (for bug resolution).
- PRODUCT_OWNER_AGENT (for acceptance criteria).

### Out of Scope
- Changing product scope without alignment with PRODUCT_OWNER_AGENT.

---

## 9. DEVOPS_RELEASE_AGENT (Optional / Future)

### Purpose
Manage CI/CD, builds, signing, and Play Store release.

### Responsibilities
- Set up CI (tests, lint, formatting).
- Configure build flavors (dev, staging, prod).
- Handle signing keys and Play Store pipeline.
- Maintain release notes and rollback procedures.

### Inputs
- Source code from dev agents.
- Test status from QA_AGENT.

### Outputs
- Signed APK/AAB builds.
- Release pipeline documentation.

### Collaborates With
- FLUTTER_APP_ARCHITECT_AGENT & FLUTTER_FRONTEND_AGENT.
- QA_AGENT for go/no-go decisions.
- PRODUCT_OWNER_AGENT for release timing and content.

---

## 10. Collaboration Rules

1. **Single Source of Truth:**  
   - Any change in scope, flows, or major behavior must first be reflected in `PRD.md` by PRODUCT_OWNER_AGENT.

2. **Design Before Build:**  
   - UX_UI_AGENT produces or updates Figma flows before FLUTTER_FRONTEND_AGENT implements major UI changes.

3. **Contract-First for APIs:**  
   - BACKEND_API_AGENT provides contracts (OpenAPI or similar).
   - Flutter agents integrate against those contracts; any breaking change must be versioned or communicated.

4. **Content & AI Alignment:**  
   - CONTENT_BOOK_AGENT and AI_ORCHESTRATION_AGENT align so that AI responses are consistent with the textbook content and board syllabus.

5. **Testing Gate:**  
   - QA_AGENT must validate core flows (from PRD) before release.

---