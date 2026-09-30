# Interna API and System Specification

## 1. System Overview and Authentication

### 1.1 Authentication Protocol
The backend uses **Supabase Auth** as the identity provider. 
- All protected endpoints require a Supabase Access Token (JWT) sent via HTTP Authorization header.
- On the user's first request to any protected route, the backend automatically provisions their record in PostgreSQL with role `STUDENT` by default (or the role passed in Supabase metadata).

```http
Authorization: Bearer <SUPABASE_JWT_ACCESS_TOKEN>
Content-Type: application/json
```

### 1.2 User Roles
- `STUDENT`: Can manage personal profile, upload resumes, view/save internships, submit applications.
- `COMPANY`: Can manage company profile, publish and manage internships, review applicants.

### 1.3 Standard Response Formats

#### Paginated List Response
```json
{
  "data": [],
  "meta": {
    "total": 42,
    "page": 1,
    "limit": 10,
    "totalPages": 5,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

#### Error Response
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request"
}
```

---

## 2. Core Entities and Schemas

### 2.1 User
```typescript
interface User {
  id: string;              // UUID from Supabase Auth
  email: string;
  provider: "GOOGLE" | "EMAIL";
  providerID?: string;
  role: "STUDENT" | "COMPANY";
  createdAt: string;       // ISO 8601
  updatedAt: string;       // ISO 8601
}
```

### 2.2 StudentProfile
```typescript
interface StudentProfile {
  id: string;              // UUID
  userId: string;          // 1:1 relation to User.id
  firstName: string;
  lastName: string;
  dob: string;             // ISO 8601 Date
  gender: "MALE" | "FEMALE" | "OTHER";
  currentAddress: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}
```

### 2.3 Company
```typescript
interface Company {
  id: string;              // UUID
  userId: string;          // 1:1 relation to User.id
  name: string;
  logoUrl?: string;
  website?: string;
  contact: string;
  industry: string;
  description?: string;
  verified: boolean;       // Default false
  createdAt: string;
  updatedAt: string;
}
```

### 2.4 Internship
```typescript
interface Internship {
  id: string;              // UUID
  companyId: string;       // Foreign key to Company.id
  title: string;
  description?: string;
  location: string;
  responsibilities: string;
  requirements: string;
  position: number;        // Default 1
  type: "REMOTE" | "ONSITE" | "HYBRID";
  deadline: string;        // ISO 8601 Date
  status: "OPEN" | "CLOSED";
  createdAt: string;
  updatedAt: string;
}
```

### 2.5 Application
```typescript
interface Application {
  id: string;
  internshipId: string;
  studentId: string;
  resumeId: string;
  coverLetter?: string;
  portfolioLink?: string;
  status: "PENDING" | "REVIEWED" | "INTERVIEW" | "ACCEPTED" | "REJECTED";
  appliedAt: string;
  updatedAt: string;
}
```

---

## 3. Endpoints Specification

### 3.1 Internship Endpoints (`/internships`)

#### GET /internships
- **Access:** Public
- **Query Parameters:**
  - `page` (number, optional, default: 1, min: 1)
  - `limit` (number, optional, default: 10, min: 1, max: 50)
  - `search` (string, optional, searches title and description)
  - `type` (string, optional: `REMOTE`, `ONSITE`, `HYBRID`)
  - `location` (string, optional)
- **Response:** `PaginatedResult<Internship>`

#### GET /internships/:id
- **Access:** Public
- **Response:** Single `Internship` with company relation and `requiredSkills`.

#### GET /internships/company/me
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Response:** Array of `Internship` posted by current company.

#### POST /internships
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "title": "Flutter Developer Intern",
  "description": "Build mobile user interfaces",
  "location": "Phnom Penh",
  "responsibilities": "Develop UI screens, integrate APIs",
  "requirements": "Dart, Flutter, Git",
  "position": 2,
  "type": "HYBRID",
  "deadline": "2026-10-31T00:00:00.000Z",
  "skillIds": ["uuid-skill-1", "uuid-skill-2"]
}
```
- **Response:** Created `Internship` record with status `201`.

#### PATCH /internships/:id
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:** Partial `CreateInternshipDTO`.

#### PATCH /internships/:id/status
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "status": "CLOSED"
}
```

#### DELETE /internships/:id
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Response:** `200 OK` (blocked if active applicants exist).

---

### 3.2 Company Endpoints (`/company`)

#### GET /company
- **Access:** Public
- **Query Parameters:** `page`, `limit`, `search`, `industry`
- **Response:** `PaginatedResult<Company>`

#### GET /company/:id
- **Access:** Public
- **Response:** `Company` details and active internships.

#### GET /company/profile/me
- **Access:** Authenticated
- **Headers:** `Authorization: Bearer <token>`
- **Response:** Company profile for logged-in user.

#### POST /company/profile
- **Access:** Authenticated (`Role.COMPANY`)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "name": "Interna Tech",
  "industry": "Software",
  "contact": "+85512345678",
  "website": "https://interna.io",
  "description": "Tech recruitment startup",
  "logoUrl": "https://storage.supabase.co/..."
}
```

#### PATCH /company/profile
- **Access:** Authenticated (`Role.COMPANY`)
- **Request Body:** Partial fields of `CreateCompanyDTO`.

#### DELETE /company/profile
- **Access:** Authenticated (`Role.COMPANY`)
- **Response:** `200 OK` (blocked if open internships exist).

#### PATCH /company/:id/verify
- **Access:** Admin
- **Request Body:** `{"verified": true}`

---

### 3.3 Student Endpoints (`/student`)

#### GET /student/profile/me
- **Access:** Authenticated
- **Headers:** `Authorization: Bearer <token>`
- **Response:** `StudentProfile` with skills and resumes.

#### GET /student/profile/:id
- **Access:** Public
- **Response:** Public profile of a student.

#### POST /student/profile
- **Access:** Authenticated (`Role.STUDENT`)
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
```json
{
  "firstName": "Sophea",
  "lastName": "Chan",
  "dob": "2003-05-15T00:00:00.000Z",
  "gender": "FEMALE",
  "currentAddress": "Phnom Penh",
  "description": "CS Student at CamTech"
}
```

#### PATCH /student/profile
- **Access:** Authenticated (`Role.STUDENT`)
- **Request Body:** Partial fields of `CreateStudentProfileDTO`.

#### DELETE /student/profile
- **Access:** Authenticated (`Role.STUDENT`)
- **Response:** `200 OK` (blocked if active applications exist).

---

### 3.4 User Endpoints (`/users`)

#### GET /users
- **Access:** Admin
- **Query Parameters:** `page`, `limit`
- **Response:** `PaginatedResult<User>` (passwords excluded).

#### GET /users/:id
- **Access:** Authenticated / Admin
- **Response:** Single user account details.

#### PATCH /users/:id
- **Access:** Authenticated / Admin
- **Request Body:** `{"email": "new@mail.com", "role": "STUDENT"}`

#### DELETE /users/:id
- **Access:** Admin
- **Response:** `200 OK`.
