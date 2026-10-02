# Employee Management & Task API

> **Step-by-Step .NET Project Building + Learning Guide**  
> **Target Role:** Senior Analyst / .NET Developer  
> **Goal:** Build an interview-ready ASP.NET Core Web API while demonstrating mastery over C#, EF Core, LINQ, JWT Authentication, Dependency Injection, Middleware, and Docker.

---

## 🏗️ Target Architecture

```
Client / Swagger / Bootstrap UI
        │
        ▼
   ASP.NET Core Web API
        │
        ▼
   Custom Exception Middleware
        │
        ▼
   Controllers ([Authorize], REST endpoints)
        │
        ▼
   Service Layer (IEmployeeService, IAuthService - Scoped DI)
        │
        ▼
   EF Core / LINQ Queries (Deferred Execution)
        │
        ▼
   Database (SQLite / SQL Server)
```

### 🔑 Authentication Flow
```
User -> POST /api/auth/login -> Validate Credentials -> Generate JWT Token
                                                               │
Client sends Header: "Authorization: Bearer <token>" ◄──────────┘
        │
        ▼
JWT Middleware validates signature & expiry -> [Authorize] Controller Endpoint
```

---

## 🛠️ Project Stack

| Technology | Why You Use It | How It Works In This Project |
| :--- | :--- | :--- |
| **C# 12 / .NET 8** | Main backend programming language | Business logic, entities, services, controllers, and middleware. |
| **ASP.NET Core Web API** | Build REST endpoints | Controllers receive HTTP requests and return JSON responses. |
| **Entity Framework Core** | ORM / Database access | `DbContext` maps application models to relational tables. |
| **LINQ** | Query and filter data | Filter by department/status, sort by salary/name via C# queries. |
| **JWT Authentication** | API Security & Authorization | Login produces a signed token passed in `Authorization: Bearer` headers. |
| **Dependency Injection** | Manage object lifetimes | `AddScoped` registers services and injects them into controllers. |
| **Custom Middleware** | Global HTTP error handling | Catches unexpected runtime exceptions and returns standard JSON errors. |
| **Swagger / OpenAPI** | API documentation & testing | Interactive testing UI with JWT Bearer authorization support. |
| **Bootstrap 5 + JS** | Responsive Frontend Dashboard | Single-page UI dashboard for employee CRUD and login without extra setup. |
| **Docker** | Containerization | Multi-stage Dockerfile for packaging and deployment. |

---

## 📁 Project Directory Structure

```
EmployeeManagementApi/
├── Controllers/
│   ├── AuthController.cs          # Login & Registration endpoints (/api/auth)
│   └── EmployeesController.cs     # Protected Employee REST CRUD endpoints (/api/employees)
├── Data/
│   ├── ApplicationDbContext.cs    # EF Core DbContext mapping entities to tables
│   └── DbInitializer.cs           # Automatic database creation and sample seeding
├── DTOs/
│   ├── AuthResponseDto.cs         # JWT Token response model
│   ├── CreateEmployeeDto.cs       # Employee creation payload with validation
│   ├── EmployeeDto.cs             # API output representation
│   ├── LoginDto.cs                # Credentials payload
│   ├── RegisterDto.cs             # User registration payload
│   └── UpdateEmployeeDto.cs       # Employee update payload
├── Middleware/
│   └── ExceptionHandlingMiddleware.cs  # Global exception handling middleware
├── Models/
│   ├── Employee.cs                # Employee domain model
│   └── User.cs                    # User authentication entity
├── Services/
│   ├── IAuthService.cs            # Auth service interface contract
│   ├── AuthService.cs             # SHA256 password hashing & JWT generation
│   ├── IEmployeeService.cs        # Employee service interface contract
│   └── EmployeeService.cs         # LINQ & EF Core business logic implementation
├── wwwroot/
│   └── index.html                 # Bootstrap 5 + JS Employee Dashboard
├── appsettings.json               # Application configuration & connection strings
├── Dockerfile                     # Multi-stage Docker build file
├── EmployeeManagementApi.csproj   # Project file with NuGet dependencies
├── Program.cs                     # Application startup, DI & HTTP pipeline setup
└── README.md                      # Comprehensive project documentation
```

---

## 🚀 Getting Started

### Prerequisites
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download) installed.

### 1. Run Locally
```bash
# Navigate to project folder
cd Employee-Management-Task-API

# Restore dependencies & run application
dotnet run
```

Access the application in your browser:
- **Web UI Dashboard:** `http://localhost:5000` or `https://localhost:5001`
- **Swagger Interactive API Documentation:** `http://localhost:5000/swagger`

---

## 🔐 Default Demo Accounts

| Role | Username | Password |
| :--- | :--- | :--- |
| **Admin** | `admin` | `AdminPassword123!` |
| **Developer** | `dev` | `DevPassword123!` |

---

## 📡 API Endpoints Summary

### Authentication Endpoints (`/api/auth`)
- `POST /api/auth/login`: Authenticate user and receive JWT Bearer Token.
- `POST /api/auth/register`: Create a new user account.

### Employee Endpoints (`/api/employees`) - *[Protected - Requires JWT]*
- `GET /api/employees`: List all employees. Supports query parameters:
  - `department`: Filter by department (e.g. `IT`, `HR`).
  - `active`: Filter by active status (`true` / `false`).
  - `sortBy`: Sort results (`salary_desc`, `salary_asc`, `name`).
- `GET /api/employees/{id}`: Get employee details by ID.
- `POST /api/employees`: Add a new employee.
- `PUT /api/employees/{id}`: Update an existing employee.
- `DELETE /api/employees/{id}`: Remove an employee.

---

## 🎯 Interview Checkpoints & Core Concepts

### 1. Dependency Injection Lifetimes
- **Transient:** New instance created every time requested. Good for lightweight stateless operations.
- **Scoped:** One instance per HTTP request scope. Used for `DbContext` and business services (`EmployeeService`).
- **Singleton:** Single instance created once and shared application-wide.

### 2. LINQ Query Execution
- Uses `IQueryable<T>` with deferred execution. Queries are only executed against the database when materialized using `.ToListAsync()` or `.FirstOrDefaultAsync()`.

### 3. Middleware Order
- Middleware components run in the order configured in `Program.cs`. Exception handling middleware is placed first to catch unhandled downstream errors across all controllers.

---

## 🐳 Docker Deployment

```bash
# Build Docker image
docker build -t employee-management-api .

# Run container on port 8080
docker run -d -p 8080:80 --name employee-api employee-management-api
```
Access at `http://localhost:8080`.
