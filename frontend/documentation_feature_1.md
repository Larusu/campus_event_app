# Documentation

Dart Frog Documentation \- [https://dart-frog.dev/](https://dart-frog.dev/)

# Feature 1 \- Authentication and Role System

| Document Info |  |
| :---- | :---- |
| Version | 1.0.0 |
| Status | DONERS\!\!\! |
| Last Updated | Jun 18, 2026 |

| Numbering format 1.2.3 1 \- Feature    2 \- Title       3 \- Subtitle |
| :---- |

# ---

## 1.1 Roles and Permissions

### 1.1.1 Roles Definitions

| Role | Description |
| :---- | :---- |
| guest | Non-school. Registered via email/password with a non-school email. |
| student | School account. Registered with a \`@[ciit.edu.ph](http://ciit.edu.ph)\` email. |
| organizer | A user (could be student) promoted by Faculty or Super Admin. |
| faculty | Promoted by Super Admin. Acts as approver. |
| super\_admin | Highest Privilege. The project team. Can manage all users. Not assignable through the app. Basically us\<3 |

### 1.1.2 Permissions

| Action | Allowed Roles | Notes |
| :---- | :---- | :---- |
| View public events | All roles |  |
| Register event | All roles |  |
| View attendee list | student, organizer, faculty, super\_admin |  |
| Create event | organizer, faculty |  |
| Approve event  | faculty | Need faculty approval for events |
| Publish event directly | faculty | Faculty skips approval |
| Reject event | faculty | Notify the organizer |
| Cancel event | organizer, faculty | soft delete; notify registered users |
| Manage event slot | organizer, faculty |  |
| Stream event | organizer, faculty | Attach stream link to event |
| Send notification | organizer, faculty | Only to registered attendees |
| Promote to organizer | faculty, super\_admin |  |
| Promote to faculty | super\_admin |  |
| Deactivate user | All roles | Soft delete, set is\_deleted \= true |
| View all users | faculty, super\_admin |  |

## ---

## 1.2 Firebase Services 

| Service | Purpose |
| :---- | :---- |
| Firebase authentication | Email/password sign-in, session management, ID Token generation |
| Firestore | Stores user profiles, roles, and account status |
| Firebase security rules | RulesBlocks direct client read/write access to Firestore; all access is routed through the Dart Frog backend via the Admin SDK |

**NOTE:** All authenticated requests must include a valid Firebase ID Token in the Authorization header as a Bearer token. The backend will reject any request with an invalid, expired, or missing token.

## ---

## 1.3 Authentication Requirements

| Endpoint / Action | Login Required | Minimum Role |
| :---- | :---- | :---- |
| Sign In | No | — |
| Get own profile | Yes | any authenticated user |
| Get another user profile | Yes | faculty, super\_admin |
| Promote user role | Yes  | faculty (to organizer), super\_admin (to faculty) |
| Deactivate user | Yes | any authenticated user(self only) |
| View all user | Yes | faculty, super\_admin |

## ---

## 1.4 Firestore Data Model

### 1.4.1 Collection: users

Path: `users/`

| `{     “uid”:          “firebase_uid”,             // string     “email”:        “jeff.marquez@ciit.edu.ph”, // string     “name”:         ”Jeff Marquez”,             // string     “contact”:      “09123456789”,              // string     “role”:         “super_admin”,              // string - guest|student|organizer|faculty|super_admin     “is_deleted”:   false,                      // boolean - soft delete     “created_at”:   "2025-01-01T00:00:00.000Z", // timestamp - first login     “updated_at”:   "2025-01-01T00:00:00.000Z", // timestamp - last profile update     “last_login_at”:"2025-01-01T00:00:00.000Z", // timestamp - update on each signin  }` |
| :---- |

### 1.4.2 Field definitions

| Field | Type | Description |
| :---- | :---- | :---- |
| `uid` | string | Firebase auth UID |
| `email` | string |  |
| `name` | string | First name \+ Last name |
| `contact` | string | The phone number, 11 digits, starts with 09\. |
| `role` | string (enum) | \`guest\` by default, \`student\` if ciit email |
| `is_deleted` | boolean | True \= account is deactivated |
| `created_at` | timestamp | Set once on first login. Never update |
| `updated_at` | timestamp | Update whenever any field changes. |
| `last_login_at` | timestamp | Update on every successful sign-in |

## ---

## 1.5 API Contracts

**Note on tokens used in this section**: This feature uses two different Firebase tokens that move in opposite directions.

A **custom token** is created by the backend (using the Admin SDK's `createCustomToken(uid)`) and sent to the frontend in the Sign In and Registration responses. The frontend exchanges it for a real session by calling `signInWithCustomToken(`).

An **ID token** is then retrieved by the frontend (via `getIdToken()`) and sent to the backend as `Authorization: Bearer <id_token>` on every other request, such as `/users/me` and `/users/{targetUID}/role`.

In short: the backend hands the frontend a custom token to start a session; the frontend then uses the ID token that session produces to authenticate everything afterward.

### 1.5.1 Sign In

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Sign in |
| `Method` | POST |
| `Route` | \``` /auth/signin` `` |
| `Description` | Sign-in an an existing email and password. Backend verifies credentials via Firebase Auth and returns user data plus a session token. |

| `Request Header` | `Content-Type: application/json` |
| :---- | :---- |
| `Request Body` | {   "email": "jeff@gmail.com",   // string, required, valid email format   "password": "Jeffoy123"      // string, required, min 8 characters `}` |
| `Success Response (HTTP 200)`  | {    "success": true,    "message": "Sign in successful.",    “custom\_token”: “eyasndjGSA0iFSA…”,    "user": {       "uid": "firebase\_uid",       "email": "jeff.[marquez@ciit.edu.ph](mailto:marquez@ciit.edu.ph)",       "name": "Jeff Marquez",       “contact”: ”09123456789”,       "role": "student"    } } |
| `Error Response` | // AUTH008 — Invalid email or password { "success": false, "code": "AUTH008", "message": "Invalid email or password." } // AUTH006 — Account is deactivated { "success": false, "code": "AUTH006", "message": "This account has been deactivated." } |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Validate email format and minimum password length client-side before submitting On success, store the returned token and user data (role, name, uid) in app state — this is what every other screen will rely on to know who's logged in Exchange the received `custom_token` for a real Firebase session using `signInWithCustomToken()`, then retrieve the ID token via `getIdToken()` for use in all subsequent authenticated requests On AUTH008, show a single generic "Invalid email or password." message rather than specifying which one was wrong On AUTH006, show the message "This account has been deactivated.” | Verify the submitted email and password against Firebase Auth — return AUTH008 if the credentials don't match Look up the corresponding Firestore document by uid after successful auth — return AUTH006 if `is_deleted` is true, before issuing any token Update `last_login_at` on successful sign-in Generate and return a session token (custom token or ID token) so the frontend can authenticate subsequent requests Never include `password` in any part of the response, even on success Generate a custom token via Firebase Admin SDK (`createCustomToken(uid)`) and include it in the response, so the frontend can establish a session immediately without a separate sign-in step |

### 1.5.2 Registration 

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Registration |
| `Method` | POST |
| `Route` | \``` /auth/register` `` |
| `Description` | Creates a new account. Role is auto-detected from email domain (@[ciit.edu.ph](http://ciit.edu.ph) \-\> student, otherwise \-\> guest) |

| `Request Header` | `Content-Type: application/json` |
| :---- | :---- |
| `Request Body` | {   "first\_name": "Jeff",        // string, required   "last\_name": "Marquez",      // string, required   "email": "jeff@gmail.com",   // string, required, valid email format   "contact": "09123456789",    // string, required, 11 digits, starts with 09   "password": "Jeffoy123"      // string, required, min 8 characters `}` |
| `Success Response (HTTP 201)` | {    "success": true,    "message": "Account created successfully.”,    “custom\_token”: “eyasndjGSA0iFSA…”,    "user": {       "uid": "firebase\_uid",       "email": "jeff.marquez@gmail.com",       "name": "Jeff Marquez",       “contact”: “09123456789”,       "role": "guest",	 	       "createdAt": "2025-01-01T00:00:00.000Z",       "lastLoginAt": "2025-06-01T08:00:00.000Z"    } } |
| `Error Response` | // AUTH002 — Email already exists { "success": false, "code": "AUTH002", "message": "An account with this email already exists." } // AUTH005 — Validation failed { "success": false, "code": "AUTH005", "message": "Invalid input. Please check your details." } // AUTH009 — Internal server error { "success": false, "code": "AUTH009", "message": "Something went wrong. Please try again." } |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Validate all fields client-side first: required fields filled, valid email format, contact matches 11-digit `09` pattern, password meets minimum length, and password/confirm-password match (confirm password is never sent to the backend) On success, store the returned token immediately and treat the user as signed in — they shouldn't have to log in again right after registering Exchange the received `custom_token` for a real Firebase session using `signInWithCustomToken()`, then retrieve the ID token via `getIdToken()` for use in all subsequent authenticated requests On AUTH002, highlight the email field specifically with "this email is already registered" rather than a generic error | Validate all incoming fields (presence, format, length) before attempting to create anything in Firebase Check Firebase Auth for an existing account with that email — return AUTH002 immediately if found, without creating a partial record Determine role from email domain (`@ciit.edu.ph` → `student`, otherwise → `guest`) before writing to Firestore Create the Firebase Auth account via Admin SDK, then create the matching Firestore document Generate and return a session token in the response so the new user is immediately authenticated, without needing a separate sign-in call Generate a custom token via Firebase Admin SDK (`createCustomToken(uid)`) and include it in the response, so the newly registered user is signed in immediately without a separate sign-in call |

### 1.5.3 Get Own Profile

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Get Own Profile |
| `Method` | GET |
| `Route` | \``` /users/me` `` |
| `Description` | Fetches the authenticated user’s profile from Firestore |

| `Request Header` | `Authorization: Bearer <firebase_id_token>` |
| :---- | :---- |
| `Request Body` | `None` |
| `Success Response (HTTP 200)` | {    "success": true,    "user": {       "uid": "firebase\_uid",       "email": "jeff.marquez@ciit.edu.ph",       "name": "Jeff Marquez",       “contact”: ”09123456789”,       "role": "student",	 	       "createdAt": "2025-01-01T00:00:00.000Z",       "lastLoginAt": "2025-06-01T08:00:00.000Z"    } } |
| `Error Response` | // AUTH001 — Invalid token { "success": false, "code": "AUTH001", "message": "Invalid or expired token." } // AUTH004 — User not found { "success": false, "code": "AUTH004", "message": "User not found." } |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Attach the stored token in the `Authorization` header on every call to this endpoint Call this on app start (or whenever the profile screen loads) to keep displayed user data in sync with Firestore On AUTH001, attempt to refresh the token silently first; only redirect to sign-in if that refresh also fails On AUTH004, sign the user out immediately — this means their account no longer exists in Firestore, which shouldn't normally happen and is worth logging for debugging | Authentication and deactivation checks are handled by shared middleware (see 1.9)  Extract the `uid` from the verified token and use it to look up the Firestore document directly Return AUTH004 if no matching document exists for that uid Return the full profile object exactly as documented, with no extra or missing fields Exclude any internal-only fields (like `is_deleted`) from the response |

NOTE: Token refresh is handled automatically by the Firebase Client SDK. The frontend should call `getIdToken()` fresh before each authenticated request rather than caching a token long-term or building manual refresh/expiry logic.

### 1.5.4 Promote User Role

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Promote User Role |
| `Method` | PATCH |
| `Route` | \``` /users/{targetUID}/role` `` |
| `Auth Required` | Faculty, super\_admin |
| `Description` | Allows authorized users to promote another user’s role.  Faculty can only assign organizer Super Admin can assign any role |

| `Request Header` | `Authorization: Bearer <firebase_id_token>` |
| :---- | :---- |
| `Request Body` | {    "target\_uid": "uid\_of\_user\_to\_promote", // string, required    "new\_role": "organizer" // string, required (organizer | faculty) }  |
| `Success Response (HTTP 200)` | {    "success": true,    "message": "User role updated to organizer.",    "target\_uid": "uid\_of\_promoted\_user",    "new\_role": "organizer" }  |
| `Error Response` | // AUTH001 — Token invalid { "success": false, "code": "AUTH001", "message": "Invalid or expired token." } // AUTH003 — Requester lacks permission { "success": false, "code": "AUTH003", "message": "You do not have permission to assign this role." } // AUTH004 — Target user not found { "success": false, "code": "AUTH004", "message": "Target user not found." } // AUTH007 — Invalid role value { "success": false, "code": "AUTH007", "message": "Invalid role specified." } |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Only display the "Promote" action to users whose own role is `faculty` or `super_admin` — don't rely on the backend's rejection as the only safeguard, since showing a disabled-looking option to unauthorized users is bad UX If the current user is `faculty`, restrict the role-selection UI to `organizer` only; don't even list `faculty` as a selectable option Attach the token in the `Authorization` header and send `target_uid` and `new_role` as documented On AUTH003, show a clear "you don't have permission to do this" message rather than a generic failure After a successful promotion, refresh the affected user's displayed role in the UI immediately, without requiring a full page reload | Authentication and deactivation checks are handled by shared middleware (see 1.9), which provides the verified requester `uid` Use that `uid` to look up the requester's current role in Firestore — never trust a role claim from the client Enforce the permission matrix strictly: `faculty` may only set `new_role` to `organizer`; only `super_admin` may set `new_role` to `faculty` Validate that `new_role` is one of the allowed enum values — return AUTH007 if not Look up the target user by `target_uid` — return AUTH004 if no matching document exists Update only the `role` and `updated_at` fields on the target document; leave everything else untouched User cannot modify their own role, even if they hold privilege |

### 1.5.5 Self-Deactivate Account

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Deactivate Own Account |
| `Method` | POST |
| `Route` | \``` /users/me/deactivate` `` |
| `Description` | Deactivates the authenticated user 's own account. Confirmed via UI dialog only. This account is irreversible. |

| `Request Header` | `Authorization: Bearer <firebase_id_token> Content-Type: application/json` |
| :---- | :---- |
| `Request Body` | `None` |
| `Success Response (HTTP 200)` | {   "success": true,   "message": "Your account has been deactivated." } |
| `Error Response` | // AUTH001 — Invalid or expired token { "success": false, "code": "AUTH001", "message": "Invalid or expired token." } // AUTH006 — Account already deactivated (caught by middleware, before route logic runs) { "success": false, "code": "AUTH006", "message": "This account has been deactivated." } |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Show explicit confirmation dialog before submitting ("This will deactivate your account. You will be signed out and must contact faculty to restore access. This cannot be undone by you.") Require the user to actively confirm (e.g. tap a clearly-labeled destructive button, not a default-focused "OK") — don't make the confirm action the easy/default path On success: immediately sign the user out locally (clear stored token/session, navigate to sign-in screen) | Verify the Firebase ID Token (handled by middleware) Look up Firestore document, check `is_deleted` (handled by middleware) — if already `true`, AUTH006 returned automatically before reaching this route Set `is_deleted = true` and bump `updated_at` on the user's Firestore document Do **not** delete the Firebase Auth account or Firestore document — soft delete only |

## 1.6 Error Codes

| Code  | HTTP Status | Description |
| :---- | :---- | :---- |
| `AUTH001` | 401 | Invalid or expired token |
| `AUTH002` | 409 | Email already exists |
| AUTH003 | 403 | Insufficient permission – role cannot perform this action |
| `AUTH004` | 404 | User not found |
| `AUTH005` | 400 | Validation failed (missing/invalid fields) |
| `AUTH006` | 403 | Account is deactivated |
| `AUTH007` | 400 | Invalid role value provided in request body. |
| `AUTH008` | 401 | Invalid email or password |
| `AUTH009` | 500 | Internal server error |
| `AUTH010` | 401 | Current password is incorrect |
| `AUTH011` | 400  | New password is the same as the current password |

## 1.7 Firestore Security Rules

All Firestore access is routed through the Dart Frog backend using the Firebase Admin SDK, which is exempt from Security Rules. The Flutter app never communicates with Firestore directly. Permission enforcement — role checks, ownership checks, soft-delete checks — is implemented entirely in backend route handlers as documented in section 1.5, not in Security Rules.

This rules file exists solely to block any accidental or unauthorized direct client access to Firestore.

| rules\_version \= '2'; service cloud.firestore {   match /databases/{database}/documents {     match /{document=\*\*} {       allow read, write: if false;     }   } } |
| :---- |

## 1.8 Testing

## 1.9 Authentication & Authorization Middleware

All protected routes (`Login Required: Yes`) pass through the same ordered sequence of checks before route-specific logic executes:

| Step | Check | Failure Response |
| :---- | :---- | :---- |
| 1 | Verify Firebase ID Token (presence, signature, expiry) | AUTH001 |
| 2 | Resolve `uid` \-\> look up firestore `users/{uid}` document | AUTH004 if not found |
| 3 | Check `is_deleted` – reject if true | AUTH006 |
| 4 | (Route-specific) Check `role` against the endpoint’s minimum required role | AUTH003 |

Steps 1–3 are universal and should be implemented once, in a shared middleware function, applied to every protected route folder (e.g. `routes/users/_middleware.dart` in Dart Frog) — not copy-pasted per-endpoint.

Step 4 is route-specific — required roles differ per endpoint (see permission in 1.1.2 and per-endpoint `Auth Required` fields in 1.5) — but should still be checked immediately after steps 1–3, before any request body parsing or business logic.

**Implementation note:** Steps 1–3 require only one Firestore read, since the document fetched in step 2 already contains the `is_deleted` flag needed for step 3 and the `role` needed for step 4\. Route handlers receive the verified `uid` and user document already resolved — they should not re-fetch or re-verify.

**Scoping note:** This middleware must be applied only to protected route folders. It must **not** wrap `/auth/signin` or `/auth/register`, which are intentionally unauthenticated.

---

# Feature 2 \- Edit Profile

| Document Info |  |
| :---- | :---- |
| Version | 2.0.0 |
| Status | Draft |
| Last Updated | Jun 20, 2026 |

Numbering format: 1.2.3 \-\> 1 feature, 2 \= title, 3 \= subtitle

## 2.1 User Flow

**Edit Name / Contact / Change Password:**

1. User opens \`Edit Profile Information\` screen (pre-filled with current name/contact from /users/me).  
2. The user edits one or more fields and enters their current password to confirm the change.  
   1. For change password:  
   2. The user enters a new password, and confirms the new password.  
   3. Frontend validates new\_password and confirm\_password match and length rules.  
3. Frontend validates fields client-side, then sends the request.  
4. Backend verifies current password, validates fields, updates Firestore. If the password changes, update the Firebase Auth password.  
5. Frontend refreshes displayed profile data from the response and shows a success message. Existing sessions remain valid.

## 2.2 Firebase Services Used

| Service | Purpose |
| :---- | :---- |
| Firebase authentication | Verifies current\_password before any change is applied; updates the account password when new\_password is provided |
| Firestore | Stores and updates name and contact |

## 2.3 Authentication Requirements

| Endpoint / Action | Login Required | Minimum Role |
| :---- | :---- | :---- |
| Update own profile | Yes | any user |

## 2.4 Firestore Data Model

No new collections or field:(.

| Field | Updated | Notes |
| :---- | :---- | :---- |
| `name` | yes | Updated if provided |
| `contact` | yes | Updated if provided. Not unique. |
| `updated_at` | yes | Update on any successful change |
| `email` | no | Cannot be changed. Permanent:( |
| `uid, role, is_deleted, created_at, last_login_at,` | ayoko | Untouched. |

## 2.5 API Contracts

### 2.5.1 Update Own Profile

| Property | Value |
| :---- | :---- |
| `Endpoint Name` | Update Own Profile |
| `Method` | PATCH |
| `Route` | \``` /users/me` `` |
| `Description` | Updates the authenticated user's own name, contact, and/or password. Supports partial updates. Current\_password is always required to authorize the change |

| `Request Header` | `Authorization: Bearer <firebase_id_token> Content-Type: application/json` |
| :---- | :---- |
| `Request Body` | {    "current\_password”: “Jeffoy123”, // string, required, always    “name”: “Jefferson Dahmer”,      // string, optional    “contact”: “0991235125”          // string, optional, 11 digits, starts with 09    “new\_password”: “NewPass456”     // string, optional `}` |
| `Success Response (HTTP 200)`  | {    “success”: true,    “message”: "Profile updated successfully.",    "user": {       "uid": "firebase\_uid",       "email": "jeff.[marquez@ciit.edu.ph](mailto:marquez@ciit.edu.ph)",       "name": "Jefferson Dahmer",       “contact”: ”0991235125”,       "role": "student",       “updatedAt”: "2026-06-22T10:00:00.000Z"    } } |
| `Error Response` | // AUTH001 — Invalid or expired token { "success": false, "code": "AUTH001", "message": "Invalid or expired token." } // AUTH004 — User not found { "success": false, "code": "AUTH004", "message": "User not found." } // AUTH005 — Validation failed { "success": false, "code": "AUTH005", "message": "Invalid input. Please check your details." } // AUTH010 — Current password incorrect { "success": false, "code": "AUTH010", "message": "Current password is incorrect." } // AUTH011 — New password same as current password { "success": false, "code": "AUTH011", "message": "New password must be different from your current password." }  |

**RESPONSIBILITIES**

| Frontend | Backend |
| :---- | :---- |
| Validate contact format (11 digits, starts with 09\) and name (non-empty) client-side before submitting, only for fields the user actually changed Always require `current_password` in the form, on every submission If the user is changing their password, validate new\_password meets 	minimum length (8 characters) and that `confirm_password` matches it. Do not send `confirm_password` to the backend On success, update the locally stored user state (name, contact) with the values returned in the response On AUTH010, show "Current password is incorrect" directly on the password field, not as a generic error On AUTH011, show "New password must be different from your current password" on the new password field Do not display any field or option to change email After a successful password change, do not force sign-out — the current 	session remains valid | Authentication and deactivation checks are handled by shared middleware (see 1.9) Re-verify `current_password` against Firebase Auth for the requesting uid — return AUTH010 if it does not match. This check runs before any field is updated, regardless of which fields are present in the 	request Treat 	the request as all-or-nothing: if `current_password` is invalid, 	reject the entire request If `new_password` is present in the body: confirm it is different from 	`current_password` (return AUTH011 if identical), and update the password in Firebase Auth via the Admin SDK Never accept or process an email field Bump 	`updated_at` on any successful change Never 	include password (current or new) in any part of the response, even on success Reject with AUTH005 if `name`, `contact`, and `new_password` are all absent from the request body |

## 2.6 Validation Rules

| Field | Rule |
| :---- | :---- |
| current\_password | Required on every request |
| name | Optional; if present, required (non-empty), |
| contact | Optional; if present, must be 11 digits and start with 09\. Not unique. |
| new\_password | Optional; if present, minimum 8 characters, and must differ from current\_password |
| confirm\_password | Required only if new\_password present. Client-side validation only — must match new\_password before submitting |
| email | Not accepted on this endpoint |
| (request as a whole) | At least one of `name`, `contact`, `new_password` must be present — reject with AUTH005 if all are absent |

## ---

# Feature 2 \- Edit Profile

| Document Info |  |
| :---- | :---- |
| Version | 3.0.0 |
| Status | Draft |
| Last Updated | Jun 22, 2026 |

