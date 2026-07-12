# Product Portal

A professional-grade Spring Boot e-commerce platform demonstrating enterprise-level architecture, best practices, and scalability patterns.

## 🎯 Project Overview

Product Portal is a comprehensive backend solution for managing users, products, and catalog hierarchies. Built with Spring Boot 4.1.0, it implements:

- **Two-Query Pagination Pattern** — Scalable, N+1 query-safe pagination with fetch-joins
- **Custom Multi-Column Sorting** — SQL injection-safe sort parameter validation
- **Enterprise Security** — JWT authentication, multi-role RBAC, scoped permissions, and organization-aware access
- **AOP Logging & Performance Monitoring** — Execution time tracking via AspectJ
- **Hierarchical Category Management** — Recursive CTEs with native SQL queries
- **Comprehensive API Documentation** — OpenAPI 3.0 (Swagger) integration

---

## 📋 Table of Contents

- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [Getting Started](#getting-started)
- [API Endpoints](#api-endpoints)
- [Database Schema](#database-schema)
- [Running Tests](#running-tests)
- [Performance Optimization](#performance-optimization)
- [Contributing](#contributing)

---

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Framework** | Spring Boot | 4.1.0 |
| **Language** | Java | 25 |
| **Build Tool** | Maven | 3.9+ |
| **Database** | MySQL | 8.0+ |
| **Security** | Spring Security + JWT | 0.13.0 |
| **API Docs** | Springdoc OpenAPI | 2.8.14 |
| **Validation** | Jakarta Bean Validation | 3.0+ |
| **Logging** | SLF4J + Logback | - |
| **AOP** | Spring AOP | - |

---

## 🏗️ Architecture

### Core Modules

```
com.elvencode.productportal
├── user                          # User management & authentication
│   ├── controller                # REST endpoints
│   ├── service                   # Business logic (two-query pattern)
│   ├── repository                # Data access (JPA + native queries)
│   ├── entity                    # Domain models
│   ├── dto                       # Request/Response DTOs
│   └── util                      # Sort validation, utilities
├── access                        # Role, permission, and assignment management
│   ├── role                      # Role entities & repository
│   ├── permission                # Permission grants and scopes
│   └── assignment                # User role assignments
├── organization                  # Organizations and memberships
├── catalog                       # Product & category management
│   ├── product                   # Product entities & queries
│   └── category                  # Hierarchical categories (recursive CTEs)
└── common                        # Cross-cutting concerns
    ├── aop/aspect               # Logging & performance monitoring
    ├── dto                      # Common response DTOs
    ├── exception                # Global exception handling
    └── config                   # Application configuration
```

### Design Patterns

1. **Two-Query Fetch-Join Pattern**
   - Query 1: Paginate over IDs (lightweight)
   - Query 2: Fetch full entities with associations via fetch-join
   - Prevents Hibernate pagination bugs with collections
   - Avoids N+1 queries on lazy-loaded associations

2. **Service-Repository Pattern**
   - Clean separation of concerns
   - Transaction management at service layer
   - Repository focuses on data access

3. **DTO Mapping**
   - Request/Response DTOs decouple API contracts from domain models
   - MapStruct-ready architecture (mapper classes present)

4. **Global Exception Handling**
   - Centralized error mapping to HTTP status codes
   - Consistent error response format

---

## ✨ Features

### User Management
- ✅ User registration with primary organization membership and default role assignment
- ✅ Get user details by username with memberships, roles, status, and addresses
- ✅ **Paginated user listing by status** with custom sorting
- ✅ Password hashing (BCrypt)
- ✅ Unique constraint validation (username, email, phone)

### Authentication & Authorization
- ✅ JWT token-based authentication
- ✅ Fail-fast JWT signing secret validation
- ✅ Multi-role RBAC with permission authorities
- ✅ Spring Security integration
- ✅ Stateless bearer token validation

### API Documentation
- ✅ OpenAPI 3.0 (Swagger) auto-documentation
- ✅ Comprehensive endpoint descriptions
- ✅ Example request/response payloads
- ✅ Swagger UI at `/swagger-ui.html`

### Performance Optimization
- ✅ Two-query pagination (scalable, memory-bounded)
- ✅ Fetch-joins for eager loading (N+1 prevention)
- ✅ @EntityGraph annotations (JPA optimization)
- ✅ Execution time monitoring (AOP)
- ✅ Query result mapping with order preservation

### Monitoring & Logging
- ✅ Structured logging via SLF4J
- ✅ Execution time tracking (INFO level)
- ✅ AspectJ-based cross-cutting concerns
- ✅ Method-level performance metrics

---

## 🚀 Getting Started

### Prerequisites

```bash
# Required
- Java 25+
- Maven 3.9+
- MySQL 8.0+
- Git

# Optional
- Docker & Docker Compose (for MySQL containerization)
- Postman (for API testing)
```

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/productportal.git
   cd productportal
   ```

2. **Configure database:**
   - Edit `src/main/resources/application.yml` or `application.properties`
   - Set MySQL connection details:
     ```yaml
     spring:
       datasource:
         url: jdbc:mysql://localhost:3306/productportal
         username: root
         password: your_password
       jpa:
         hibernate:
           ddl-auto: validate  # or 'update' for dev
     ```

3. **Configure JWT signing:**
   - `src/main/resources/application.properties` contains:
     ```properties
     jwt.secret=${JWT_SECRET}
     ```
   - Keep the real secret outside source control.
   - Set `JWT_SECRET` before starting the app.
   - The secret must be at least 64 UTF-8 bytes.
   - Generate a strong secret with PowerShell:
     ```powershell
     $bytes = New-Object byte[] 64
     [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
     $env:JWT_SECRET = [Convert]::ToBase64String($bytes)
     ```
   - Or set an existing secret manually in PowerShell:
     ```powershell
     $env:JWT_SECRET="replace-with-a-64-plus-character-secret-from-your-secret-manager"
     ```
   - For Bash:
     ```bash
     export JWT_SECRET="replace-with-a-64-plus-character-secret-from-your-secret-manager"
     ```
   - IntelliJ IDEA:
     1. Open `Run` -> `Edit Configurations...`
     2. Select `ProductportalApplication`
     3. Click `Modify options`
     4. Enable `Environment variables`
     5. Add `JWT_SECRET=your-64-plus-character-secret`
     6. Apply and run

4. **Configure CORS origins:**
   - `SECURITY_CORS_ALLOWED_ORIGINS` is required.
   - Use exact origins only. For local frontend development:
     ```powershell
     $env:SECURITY_CORS_ALLOWED_ORIGINS="http://localhost:5173"
     ```
   - For production:
     ```bash
     export SECURITY_CORS_ALLOWED_ORIGINS="https://portal.example.com"
     ```
   - Multiple origins can be comma-separated.

5. **Start MySQL (via Docker Compose):**
   ```bash
   docker-compose up -d
   ```

6. **Build and run:**
   ```bash
   mvn clean install
   mvn spring-boot:run
   ```

7. **Verify startup:**
   - API base URL: `http://localhost:8080`
   - Swagger UI: `http://localhost:8080/swagger-ui.html`

### Common Startup Failures

#### CORS origin policy is missing

If startup fails with:

```text
Failed to bind properties under 'security.cors' to com.elvencode.productportal.security.config.CorsProperties
Reason: java.lang.IllegalArgumentException: security.cors.allowed-origins or security.cors.allowed-origin-patterns must be configured
```

configure at least one exact frontend origin before starting the application.

PowerShell:

```powershell
$env:SECURITY_CORS_ALLOWED_ORIGINS="http://localhost:5173"
$env:JWT_SECRET="replace-with-a-64-plus-character-secret-from-your-secret-manager"
.\mvnw.cmd spring-boot:run
```

Bash:

```bash
export SECURITY_CORS_ALLOWED_ORIGINS="http://localhost:5173"
export JWT_SECRET="replace-with-a-64-plus-character-secret-from-your-secret-manager"
./mvnw spring-boot:run
```

IntelliJ IDEA:

```text
Run -> Edit Configurations -> ProductportalApplication -> Environment variables

JWT_SECRET=replace-with-a-64-plus-character-secret-from-your-secret-manager
SECURITY_CORS_ALLOWED_ORIGINS=http://localhost:5173
```

For production, set the real frontend origin:

```bash
export SECURITY_CORS_ALLOWED_ORIGINS="https://portal.example.com"
```

Do not use `*` while `security.cors.allow-credentials=true`. Credentialed browser requests require explicit origins or safe origin patterns.

#### JWT secret is missing or too weak

If startup fails because `jwt.secret` cannot be bound or validated, set `JWT_SECRET` outside source control. It must contain at least 64 UTF-8 bytes.

PowerShell generator:

```powershell
$bytes = New-Object byte[] 64
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$env:JWT_SECRET = [Convert]::ToBase64String($bytes)
```

---

## 📡 API Endpoints

### User Endpoints

#### Register User
```http
POST /users/register
Content-Type: application/json

{
  "username": "amal.perera",
  "fullName": "Amal Perera",
  "email": "amal@example.com",
  "phoneNumber": "+94771234567",
  "password": "SecurePassword123!"
}
```

#### Get User Details by Username
```http
GET /users/username/{username}

# Example
GET /users/username/amal.perera
```

#### Get Paginated Users by Status (with Sorting)
```http
GET /users/status/{status}?page=0&size=20&sort=username,desc

# Examples
GET /users/status/ACTIVE?page=0&size=10
GET /users/status/ACTIVE?page=0&size=10&sort=email,asc
GET /users/status/ACTIVE?page=0&size=10&sort=createdAt,desc&sort=fullName,asc
```

**Sortable Columns:**
- `username` — User's login name
- `fullName` — User's display name
- `email` — Email address
- `phoneNumber` — Phone number
- `createdAt` — Account creation date
- `updatedAt` — Last update date
- `status` — Account status code

**Query Parameters:**
- `page` (int, default: 0) — Page number (0-indexed)
- `size` (int, default: 20) — Items per page
- `sort` (string) — `column,direction` (e.g., `username,desc`)

---

## 📊 Database Schema

### Key Tables

**pp_m_user** — User accounts
- `user_id` (PK)
- `username` (UNIQUE)
- `email` (UNIQUE)
- `phone_number` (UNIQUE)
- `password_hash` (hashed)
- `full_name`
- `primary_organization_id` (FK → pp_m_organization)
- `status` (FK → pp_r_user_status)
- `created_at`, `updated_at`

**pp_m_role** — Role definitions
- `role_code` (PK)
- `display_name`

**pp_m_permission** — Permission definitions
- `permission_code` (PK)
- `resource_code`, `action_code`

**pp_m_organization** — Organizations
- `organization_id` (PK)
- `organization_code` (UNIQUE)
- `display_name`

**pp_t_user_organization_membership** — User organization memberships
- `user_id`, `organization_id` (composite PK)
- `membership_status`
- `is_primary`

**pp_t_user_role_assignment** — Role assignments
- `user_id`, `organization_id`, `role_code` (composite PK)
- `is_active`, `valid_from`, `valid_until`
- `assigned_by`, `assigned_reason`, `revoked_by`, `revoked_reason`

**pp_t_role_permission_grant** — Role permission grants
- `role_code`, `permission_code` (composite PK)
- `scope_code`
- `is_active`

**pp_r_user_status** — User statuses (ACTIVE, INACTIVE, SUSPENDED, DELETED)
- `status_code` (PK)
- `is_active` (flag for logical soft-delete)

**pp_m_user_address** — User addresses (1:M)
- `address_id` (PK)
- `user_id` (FK)
- `address_line_1`, `address_line_2`
- `city`, `state`, `postal_code`, `country`

---

## 🧪 Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=UserControllerTest

# Run with coverage
mvn clean test jacoco:report
```

---

## ⚡ Performance Optimization

### Two-Query Pagination Pattern

The implementation uses a scalable two-query fetch-join pattern to avoid:
- ❌ Hibernate pagination bugs with fetch-joins and collections
- ❌ N+1 queries on lazy-loaded associations
- ❌ Memory overflow on large result sets

**Query Flow:**
1. Fetch paginated IDs (lightweight, fast)
2. Fetch full entities with associations via fetch-join
3. Preserve original ID ordering
4. Map to DTOs

### Monitoring Execution Time

Enable INFO-level logging to see query execution times:

```yaml
logging:
  level:
    com.elvencode: INFO
```

**Log Example:**
```
Successful UserServiceImpl.getAllUsersByStatus(..) after 45 ms
Failed UserServiceImpl.getAllUsersByStatus(..) after 1200 ms
```

### Learning Login Execution Trace

The login execution tracing aspect is disabled by default. Enable it only for local learning/debugging:

```properties
auth.login-trace.enabled=true
```

In IntelliJ IDEA, you can keep `application.properties` unchanged and add this as a program argument:

```text
--auth.login-trace.enabled=true
```

This traces method names and execution time during `AuthController.login()` without logging request bodies,
passwords, or JWT tokens.

---

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch:**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit changes with descriptive messages:**
   ```bash
   git commit -m "feat: add amazing feature"
   git commit -m "fix: resolve N+1 query issue"
   ```
4. **Push to branch:**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Commit Message Convention

- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code refactoring
- `docs:` — Documentation
- `test:` — Test additions/modifications
- `perf:` — Performance improvements

---

## 📝 License

This project is licensed under the MIT License — see LICENSE file for details.

---

## 📞 Support

For issues, questions, or suggestions:
- Open an [Issue](https://github.com/yourusername/productportal/issues)
- Email: support@example.com

---

## 🎓 Learning Resources

- [Spring Boot Official Documentation](https://spring.io/projects/spring-boot)
- [Spring Data JPA Guide](https://spring.io/projects/spring-data-jpa)
- [Hibernate Performance Tuning](https://hibernate.org/orm/documentation)
- [JWT Authentication](https://jwt.io)
- [REST API Best Practices](https://restfulapi.net)

---

**Built with ❤️ for enterprise-grade applications**
