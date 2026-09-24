# Interna Frontend Specification (Flutter)

Companion document to `API_DOCUMENTATION.md`.
That document describes the server. This one describes the mobile app.

- Package name: `interna`
- Flutter SDK: `^3.12.2`
- Generated from the code on branch `Sanlong-branch`, 2026-09-22.

---

## 1. System Overview and Setup

### 1.1 Entry Point

`lib/main.dart` does three things and nothing else:

1. Calls `WidgetsFlutterBinding.ensureInitialized()`.
2. Calls `Supabase.initialize()` with the values from `AppEnv`.
3. Runs `MyApp`, whose `home` is `SplashScreen`.

There is no route table. Every screen change uses `Navigator.push` with a
`MaterialPageRoute` built inline. See section 4.

### 1.2 Configuration (`lib/config/app_env.dart`)

All values come from `String.fromEnvironment`, so they can be replaced at build
time with `--dart-define`. Each one has a default for local work.

| Key | Default | Used by |
|---|---|---|
| `ENVIRONMENT` | `local/default` | `AppEnv.isDev`, `AppEnv.isProd` |
| `APP_NAME` | `Interna` | `MaterialApp.title` |
| `API_BASE_URL` | `http://10.0.2.2:3000` | `ApiClient` |
| `SUPABASE_URL` | project URL (in file) | `Supabase.initialize` |
| `SUPABASE_ANON_KEY` | publishable key (in file) | `Supabase.initialize` |
| `DEBUG_MODE` | `true` | not read yet |

`10.0.2.2` is the Android emulator's address for the host machine. On the iOS
simulator the backend must be started with
`--dart-define=API_BASE_URL=http://localhost:3000`.

Example release build:

```bash
flutter run \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://api.interna.example.com
```

### 1.3 HTTP Layer (`lib/config/api_client.dart`)

A thin static wrapper around `package:http`. It attaches the Supabase access
token to every request, which is exactly what section 1.1 of the API document
requires.

```dart
static Map<String, String> _getHeaders() {
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  return {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
```

Methods: `ApiClient.get(endpoint)`, `.post(endpoint, body)`,
`.patch(endpoint, body)`, `.delete(endpoint)`. Each takes a path such as
`/internships` and joins it to `AppEnv.apiBaseUrl`.

**Status: written but never called.** No screen imports `ApiClient` today.
Every list in the app comes from hard-coded demo data. See section 7.

### 1.4 Authentication

The app talks to Supabase directly for auth, not to the NestJS backend.

| Action | Where | Call |
|---|---|---|
| Email + password login | `login_screen.dart` | `auth.signInWithPassword()` |
| Google login | `login_screen.dart` | `auth.signInWithOAuth(OAuthProvider.google)` |
| Session watch | `login_screen.dart` `initState` | `auth.onAuthStateChange.listen(...)` |
| Sign up | not implemented | `TODO(team)` |
| Password reset | not implemented | `TODO(team)` |
| Update password | not implemented | `TODO(team)` |
| Sign out | not implemented | `TODO(team)` |

The auth state listener exists so the Google OAuth redirect can push
`HomeScreen` when the session arrives back in the app.

---

## 2. Core Models

The frontend has its own plain Dart classes. They do **not** match the backend
entities in `API_DOCUMENTATION.md` section 2. Section 7 lists the differences.

### 2.1 InternshipOpportunity

`lib/features/home/data/internship_model.dart`

```dart
class InternshipOpportunity {
  final String id;
  final String role;            // "Marketing Intern"
  final String company;         // "Chip Mong"
  final String category;        // Tech | Marketing | Design | Finance
  final String location;
  final String schedule;        // "Full-Time: 8:00 AM - 5:00 PM"
  final String paymentStatus;   // "Payment Included"
  final String deadline;        // free text, e.g. "February 14, 2026"
  final Color brandColor;       // UI only
  final String logoKey;         // UI only, picks the logo widget
  final String description;
  final List<String> requirements;
  final String stipend;         // default "$200 - $350 / month"
  final bool isSaved;
}
```

Helpers: `displayTitle` returns `"$role at $company"`. `copyWith()` returns a
changed copy.

Constant list `demoInternships` holds 7 records.

### 2.2 Demo-only models

`lib/shared/demo_data.dart`. This whole file is temporary and is deleted when
the API is connected.

```dart
class ChatPreview     { String name; String lastMessage; String timeAgo; int unreadCount; }
class ChatMessage     { String text; String time; bool isMine; }
class SavedInternship { String title; String company; String location;
                        List<String> tags; String postedAgo; String payType; }
class AppNotification { String companyName; String title; String body;
                        String timeAgo; bool isUnread; }
```

Constant lists: `demoChats` (7), `demoConversation` (5), `demoSavedInternships`
(3), `demoNotifications` (6).

---

## 3. Screen Specification

Format for each screen, matching the endpoint format in the API document:

- **File** — where the code lives
- **Opened from** — the screen that pushes it (the frontend version of a URL)
- **Input** — constructor parameters
- **State** — what the screen remembers while it is open
- **Backend need** — what it must call when the API is connected

### 3.1 Splash and Onboarding

#### SplashScreen
- **File:** `lib/features/splash/presentation/splash_screen.dart`
- **Opened from:** `MyApp.home` (app start)
- **Input:** none
- **State:** animation controller, 2600 ms timer
- **Behaviour:** pre-caches `assets/images/main_logo.png`, then
  `pushReplacement` to `LoginScreen` with a 500 ms fade
- **Backend need:** should check for an existing Supabase session and skip
  straight to `HomeScreen` when one exists. Not implemented.

#### OnboardingScreen
- **File:** `lib/features/auth/presentation/onboarding_screen.dart`
- **Opened from:** nothing. Currently reachable only through `DevMenuScreen`.
- **Input:** none
- **Behaviour:** pushes `LoginScreen`

### 3.2 Auth Screens (`lib/features/auth/`)

#### LoginScreen
- **File:** `presentation/login_screen.dart`
- **Opened from:** `SplashScreen`, `OnboardingScreen`, `backToLogin()`
- **Input:** none
- **State:** `_formKey`, `_emailController`, `_passwordController`,
  auth-state subscription
- **Validation:** `validateEmail`, `validatePassword`
- **Actions:**
  - Login → `signInWithPassword()` → `pushReplacement(HomeScreen)`
  - Google → `signInWithOAuth()`
  - Forgot password → push `ForgotPasswordScreen`
  - Sign up → push `SignupScreen`
- **Backend need:** none extra. Supabase handles it.

#### SignupScreen
- **File:** `presentation/signup_screen.dart`
- **Opened from:** `LoginScreen`
- **State:** `_fullNameController`, `_emailController`, `_passwordController`
- **Validation:** `validateFullName`, `validateEmail`, `validateNewPassword`
- **Backend need:** `auth.signUp()`, and it must write `role` into the Supabase
  user metadata. The API document section 1.1 says the backend reads the role
  from there. Right now the button only shows a SnackBar.

#### ForgotPasswordScreen
- **File:** `presentation/forgot_password_screen.dart`
- **State:** `_formKey`, `_emailController`
- **Behaviour:** pushes `CheckEmailScreen(email: ...)`
- **Backend need:** `auth.resetPasswordForEmail(email)`

#### CheckEmailScreen
- **Input:** `required String email`
- **Behaviour:** "Open mail app" pushes `ResetSuccessScreen`; "Resend" is a
  `TODO(team)`

#### ResetSuccessScreen
- **Input:** none
- **Behaviour:** CONTINUE calls `backToLogin()`. Marked `TODO(team): change
  this to the home screen`.

#### Helper: `backToLogin(BuildContext)`
- **File:** `auth_navigation.dart`
- Calls `pushAndRemoveUntil(LoginScreen, (route) => false)` so the user cannot
  press back into the reset flow.

### 3.3 Home Screens (`lib/features/home/`)

#### HomeScreen
- **File:** `presentation/home_screen.dart` (666 lines, the largest screen)
- **Opened from:** `LoginScreen`, and several `pushAndRemoveUntil` calls
- **Input:** `bool isOffline` (default `false`)
- **State:**

  | Field | Meaning |
  |---|---|
  | `_searchController` | the search box text |
  | `_selectedCategory` | `All` / `Tech` / `Marketing` / `Design` / `Finance` |
  | `_selectedLocation` | `null` means all |
  | `_paymentOnly` | paid internships only |
  | `_savedIds` | `Set<String>`, starts as `{'cm-01', 'cellcard-03'}` |
  | `_shimmerController` | loading skeleton animation |

- **Filtering:** done in memory over `demoInternships`. Search matches role,
  company, location and category.
- **Navigation out:** notification bell → `NotificationsScreen`; card tap →
  `InternshipDetailsScreen`; bottom nav → see section 4.2
- **Backend need:** `GET /internships` with `page`, `limit`, `search`, `type`,
  `location`. Saving needs a save endpoint, which the API does not have yet.

#### InternshipDetailsScreen
- **File:** `presentation/internship_details_screen.dart`
- **Input:** `required InternshipOpportunity internship`, `bool initialSaved`,
  `VoidCallback? onToggleSave`
- **Navigation out:** `CompanyProfileScreen`, `ApplicationSubmittedScreen`
- **Backend need:** `GET /internships/:id`

#### InternshipDetailsSheet
- **File:** `widgets/internship_details_sheet.dart`
- A bottom-sheet version of the screen above, same data, opened with
  `showModalBottomSheet`. Two components show the same thing; see section 7.

#### CompanyProfileScreen
- **Input:** `InternshipOpportunity? internship`, `String companyName`
- **Backend need:** `GET /company/:id`

#### ApplicationSubmittedScreen
- **Input:** `InternshipOpportunity? internship`
- Confirmation screen. Leads to `ApplicationDetailsScreen` or back to
  `HomeScreen`.
- **Backend need:** `POST /applications` — this endpoint does not exist in the
  API document.

#### ApplicationDetailsScreen
- **File:** `presentation/application_details_screen.dart` (585 lines)
- **Input:** `InternshipOpportunity? internship` (falls back to a demo record)
- Shows a status timeline built from a local `stages` list, with `isPassed`
  hard-coded as `stepIndex < 1`.
- **Backend need:** `GET /applications/:id`, and `Application.status`
  (`PENDING` … `REJECTED`) must drive the timeline instead of the fixed index.

#### CreatePostScreen
- **Input:** none
- **State:** `_titleController`, `_descController`
- **Access:** company users only, but the app has no role check yet.
- **Backend need:** `POST /internships`

#### OfflineErrorScreen
- **File:** `presentation/offline_error_screen.dart` (452 lines)
- A copy of the home layout showing skeletons and an offline message. It has
  its own bottom-nav mapping that does not match the others; see section 7.

### 3.4 Profile Screens (`lib/features/profile/`)

#### EditProfileScreen
- **File:** `presentation/edit_profile_screen.dart`
- **Opened from:** bottom nav index 4 on Home, Messages and Saved
- **State:** `_formKey`, controllers for full name, birth date, email, phone,
  location, plus a `_gender` value. All controllers start with hard-coded text.
- **Widgets:** `SoftTextField`, `showDatePicker` for the birth date
- **Actions:** three-dot menu → `UpdatePasswordScreen` or `showLogoutSheet`
- **Backend need:** `GET /student/profile/me`, `PATCH /student/profile`
- **Mismatch:** the form has `phone`; `StudentProfile` in the API has no phone
  field. The API has `firstName` + `lastName`; the form has one `fullName`.

#### UpdatePasswordScreen
- **State:** old, new and confirm password controllers
- **Validation:** `validatePassword`, `validateNewPassword`,
  `validateConfirmPassword`
- **Backend need:** `auth.updateUser(UserAttributes(password: ...))`. The API
  has no password endpoint. Currently a `TODO(team)`.

#### showLogoutSheet()
- **File:** `widgets/logout_sheet.dart`
- A bottom sheet with YES and CANCEL. Neither button signs the user out yet.

### 3.5 Messages Screens (`lib/features/messages/`)

#### MessagesScreen
- **State:** `_searchController`, `_searchText`
- Filters `demoChats` by name in memory. Row tap pushes
  `ChatScreen(contactName: ...)`.
- **Backend need:** none exists. The API document has no message endpoints.

#### ChatScreen
- **Input:** `required String contactName`
- **State:** `_messageController`, a mutable copy of `demoConversation`
- Send appends to the local list only. `TODO(team): send the message to the
  server once a backend exists.`
- **Backend need:** a messages API plus a realtime channel. Supabase Realtime
  is the obvious option because Supabase is already a dependency.

### 3.6 Saved Screen (`lib/features/saved/`)

#### SavedInternshipsScreen
- **State:** a mutable copy of `demoSavedInternships`
- Three-dot removes one card; the trash icon asks first, then clears all.
- **Backend need:** none exists. API section 1.2 promises students can save
  internships, but section 3 has no endpoint for it.

### 3.7 Notifications Screen (`lib/features/notifications/`)

#### NotificationsScreen
- **Opened from:** the bell icon on `HomeScreen`
- **State:** a mutable copy of `demoNotifications`
- "Read all" sets every `isUnread` to false in memory only.
- **Backend need:** none exists.

### 3.8 DevMenuScreen

- **File:** `lib/dev_menu_screen.dart`
- A developer-only list that pushes any screen directly, so a screen can be
  checked without walking the whole flow. It is not linked from the app.

---

## 4. Navigation

### 4.1 Main flow

```
SplashScreen
   └─ pushReplacement → LoginScreen
        ├─ push → SignupScreen
        ├─ push → ForgotPasswordScreen → CheckEmailScreen → ResetSuccessScreen
        │                                                      └─ backToLogin()
        └─ pushReplacement → HomeScreen
             ├─ bell    → NotificationsScreen
             ├─ card    → InternshipDetailsScreen
             │              ├─ CompanyProfileScreen
             │              └─ ApplicationSubmittedScreen
             │                    └─ ApplicationDetailsScreen
             └─ bottom nav (see 4.2)
```

There are no named routes. Every navigation builds the destination widget
inline, so a screen cannot be opened by name or by deep link today.

### 4.2 Bottom navigation

`AppBottomNav` (`lib/shared/widgets/shared_widgets.dart`) defines five fixed
tabs:

| Index | Icon | Label |
|---|---|---|
| 0 | home | Home |
| 1 | school | Explore |
| 2 | assignment | Tracker |
| 3 | groups | Community |
| 4 | person | Profile |

Four screens use the bar, and each one maps the indexes differently:

| Index | HomeScreen | MessagesScreen | SavedInternshipsScreen | OfflineErrorScreen |
|---|---|---|---|---|
| 0 | stay | pop to first | pop to first | HomeScreen |
| 1 | open filter sheet | pop to first | pop to first | HomeScreen |
| 2 | ApplicationDetails | ApplicationDetails | ApplicationDetails | CreatePostScreen |
| 3 | MessagesScreen | stay | MessagesScreen | MessagesScreen |
| 4 | EditProfileScreen | EditProfileScreen | EditProfileScreen | SavedInternshipsScreen |

`currentIndex` is 0 on Home, 3 on Messages, 2 on Saved, 0 on Offline. This is
the biggest inconsistency in the app; see section 7.

### 4.3 Page transitions

`SmoothFadeSlidePageTransitionsBuilder` in `lib/shared/page_transitions.dart`
is registered in `ThemeData` for every platform: a 6% slide from the right plus
a fade, `easeOutCubic`. `createSmoothPageRoute()` does the same for a single
route (320 ms).

---

## 5. Shared Widgets

### 5.1 `lib/shared/widgets/shared_widgets.dart`

| Widget | Parameters | Notes |
|---|---|---|
| `SoftTextField` | `label`, `controller`, `isPassword`, `readOnly`, `keyboardType`, `suffix`, `onTap`, `validator` | white box, soft shadow, no border |
| `InitialsAvatar` | `name`, `size`, `isSquare` | colored circle with initials; the color is derived from the name, so it never changes |
| `AppBottomNav` | `currentIndex`, `onTap` | see 4.2 |
| `WideButton` | `text`, `onPressed`, `color` | full-width button |
| `softShadow` | — | one shadow list used by every card |

`InitialsAvatar` exists on purpose. The mockups used real photos of celebrities
and real company logos. Those belong to other people, so the app does not ship
them. Replace with `Image.network` when the backend returns real URLs.

### 5.2 `lib/features/auth/widgets/auth_widgets.dart`

| Widget | Parameters |
|---|---|
| `AuthTextField` | `label`, `hint`, `controller`, `isPassword`, `keyboardType`, `validator` |
| `PrimaryButton` | `text`, `onPressed` |
| `GoogleButton` | `onPressed` |
| `BottomLinkRow` | `question`, `linkText`, `onLinkTap` |
| `AuthHeader` | `title`, `subtitle` |

Constants in the same file: screen padding 44, button height 50.

### 5.3 Home widgets

| Widget | Parameters |
|---|---|
| `InternshipCard` | `internship`, `isSaved`, `onToggleSave` |
| `CompanyLogoWidget` | `logoKey`, `companyName`, `brandColor`, `size` |
| `FilterBottomSheet` | `selectedCategory`, `selectedLocation`, `paymentOnly`, `onApply` |

`FilterBottomSheet` holds its own category list and a location list
(`All Locations`, `Khan Sen Sok`, `Khan Toul Kork`, `Chamkar Mon`).

---

## 6. Design Tokens and Validation

### 6.1 Colors (`lib/shared/app_colors.dart`)

| Name | Value | Used for |
|---|---|---|
| `primaryBlue` | `#3B66FF` | buttons, links, selected icons |
| `headerBlueLight` | `#4A7BFF` | profile header gradient top |
| `headerBlueDark` | `#1E5CFB` | profile header gradient bottom |
| `heading` | `#0D0141` | titles and field labels |
| `bodyText` | `#524B6C` | paragraphs |
| `hintText` | `#6D678B` | placeholders, small gray times |
| `border` | `#C6C6C6` | auth field outline |
| `lightFill` | `#F4F4F4` | search bar, chips |
| `unreadBlue` | `#EBF0FF` | unread notification row |
| `otherBubble` | `#E7ECFF` | other person's chat bubble |
| `danger` | `#DC2626` | CANCEL, delete |
| `online` | `#2E9E4F` | online dot, double check |

`AuthColors` still exists but only forwards five names to `AppColors`. New code
should import `AppColors`.

Font: Plus Jakarta Sans, through `google_fonts: ^8.2.1`.
Design frame: 402 x 880 (iPhone 16 Pro at 2x).

### 6.2 Validators (`lib/shared/validators.dart`)

| Function | Rule |
|---|---|
| `validateRequired(value, fieldName)` | not empty |
| `validateEmail` | not empty, matches `^[\w.+-]+@[\w-]+\.[\w.-]+$` |
| `validatePassword` | not empty, at least 8 characters |
| `validateNewPassword` | the above, plus one letter and one digit |
| `validateConfirmPassword(value, newPassword)` | must match |
| `validateFullName` | not empty, at least 2 characters |

All messages are written in full sentences and live here, not in the screens,
so login and sign up show the same wording.

### 6.3 Assets (`assets/images/`)

`main_logo.png`, `google_logo.png`, `illustration_intern.png`,
`illustration_key.png`, `illustration_mail_sent.png`,
`illustration_success.png`.

The illustrations were cropped from JPEG screenshots. Swap in the designer's
original files under the same names; no code change is needed.

---

## 7. Known Gaps

### 7.1 The app is not connected to the backend

`ApiClient` is written and correct, but no screen calls it. Only login and
Google sign-in touch a server, and they go to Supabase, not to NestJS. Every
list on every screen is a constant in `demo_data.dart` or
`internship_model.dart`.

### 7.2 Screens with no API behind them

| Screen | Needs |
|---|---|
| MessagesScreen, ChatScreen | a messages API; nothing in `API_DOCUMENTATION.md` |
| SavedInternshipsScreen | a save endpoint; API section 1.2 promises it, section 3 has none |
| NotificationsScreen | a notifications API; nothing in the document |
| ApplicationSubmittedScreen, ApplicationDetailsScreen | `/applications` routes; the `Application` entity is defined but has no endpoints |
| CreatePostScreen | `POST /internships` exists, but needs a `GET /skills` list to fill `skillIds` |

### 7.3 Model mismatches with the API

| Frontend | Backend | Problem |
|---|---|---|
| `fullName` (one field) | `firstName` + `lastName` | must split or the API must change |
| `phone` on the profile form | not in `StudentProfile` | one side has to add or drop it |
| no avatar field | `Company.logoUrl` exists, student has none | the profile avatar stays fake |
| `deadline` as free text | `deadline` as ISO 8601 | frontend needs date parsing and formatting |
| `category` (Tech, Marketing, …) | `requiredSkills` relation | not the same idea; needs a decision |
| `type` (`REMOTE`/`ONSITE`/`HYBRID`) missing | `Internship.type` | the frontend shows `schedule` text instead |

### 7.4 Bottom navigation is inconsistent

The table in 4.2 shows the same index doing different things on different
screens. Index 3 is labelled "Community" but opens Messages everywhere. Index 2
is "Tracker" but opens Application Details on three screens and Create Post on
the offline screen. There is no Saved tab at all, even though a Saved screen
exists. On Saved, tapping the tab you are already on navigates away.

This needs one decision from the team: fix the five tabs, then make every
screen use the same mapping.

### 7.5 Duplicated screens

- `InternshipDetailsScreen` and `internship_details_sheet.dart` show the same
  internship in two forms.
- `OfflineErrorScreen` (452 lines) repeats the home layout instead of
  `HomeScreen` rendering an offline state. `HomeScreen` already takes an
  `isOffline` flag.
- `lib/main.dart.backup` is still in the repository.

### 7.6 No state management and no routes

Everything is `setState` inside each screen. Saved internships live in
`HomeScreen._savedIds`, so the Saved screen cannot see them. Once the API is
connected, shared state (auth session, saved list, unread counts) needs one
owner. The team should pick the simplest option that works before adding a
package.

There is no route table, so no deep links and no `Navigator.pushNamed`.

### 7.7 Missing auth pieces

Sign up, password reset, password update and log out are all still
`TODO(team)`. Sign up in particular must set `role` in the Supabase user
metadata, because the backend reads the role from there on the user's first
request.

---

## 8. Open Questions for the Team

1. Who owns the bottom navigation bar, and what are the five real tabs?
2. Are Messages, Saved and Notifications in scope for this term? If yes, who
   writes those endpoints?
3. Will `StudentProfile` get an avatar field and a phone field?
4. One name field or two?
5. Which state solution do we use once the API is connected?
6. `CreatePostScreen` is for companies. When does the app start checking the
   user role?
