$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:5000"
$passed = 0
$failed = 0

function Assert-Test {
    param(
        [string]$TestName,
        [bool]$Condition,
        [string]$Message = ""
    )
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $script:passed++
    } else {
        Write-Host "  [FAIL] $TestName - $Message" -ForegroundColor Red
        $script:failed++
    }
}

function Request-Status {
    param(
        [string]$Uri,
        [string]$Method = "GET",
        [hashtable]$Headers = @{},
        [string]$Body = "",
        [string]$ContentType = "application/json"
    )
    try {
        $params = @{
            Uri = $Uri
            Method = $Method.ToUpper()
            Headers = $Headers
            UseBasicParsing = $true
        }
        if ($Body) {
            $params["Body"] = $Body
            $params["ContentType"] = $ContentType
        }
        $res = Invoke-WebRequest @params
        return [int]$res.StatusCode
    } catch {
        if ($_.Exception.Response) {
            return [int]$_.Exception.Response.StatusCode
        }
        return 0
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " FULL AUTOMATED TEST SUITE: Employee Management & Task API" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------
# 1. SECURITY & UNAUTHENTICATED REJECTION TESTS
# ---------------------------------------------------------
Write-Host "--- 1. Testing Unauthenticated Endpoint Rejection (401 Unauthorized) ---" -ForegroundColor Yellow

$statusGet = Request-Status -Uri "$baseUrl/api/employees" -Method GET
Assert-Test "GET /api/employees rejects unauthenticated requests with 401" ($statusGet -eq 401) "Got status $statusGet"

$statusGetId = Request-Status -Uri "$baseUrl/api/employees/1" -Method GET
Assert-Test "GET /api/employees/1 rejects unauthenticated requests with 401" ($statusGetId -eq 401) "Got status $statusGetId"

$statusPost = Request-Status -Uri "$baseUrl/api/employees" -Method POST -Body (@{ name="Test" } | ConvertTo-Json)
Assert-Test "POST /api/employees rejects unauthenticated requests with 401" ($statusPost -eq 401) "Got status $statusPost"

$statusDel = Request-Status -Uri "$baseUrl/api/employees/1" -Method DELETE
Assert-Test "DELETE /api/employees/1 rejects unauthenticated requests with 401" ($statusDel -eq 401) "Got status $statusDel"

# ---------------------------------------------------------
# 2. AUTHENTICATION & JWT TOKEN TESTS
# ---------------------------------------------------------
Write-Host ""
Write-Host "--- 2. Testing Authentication & JWT Generation (/api/auth) ---" -ForegroundColor Yellow

# Test invalid login credentials
$badLogin = @{ username = "admin"; password = "WrongPassword!" } | ConvertTo-Json
$statusBadLogin = Request-Status -Uri "$baseUrl/api/auth/login" -Method POST -Body $badLogin
Assert-Test "POST /api/auth/login rejects invalid credentials with 401" ($statusBadLogin -eq 401) "Got status $statusBadLogin"

# Test valid login
$validLogin = @{ username = "admin"; password = "AdminPassword123!" } | ConvertTo-Json
$loginRes = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $validLogin -ContentType "application/json"
$token = $loginRes.token
Assert-Test "POST /api/auth/login returns valid JWT token" (![string]::IsNullOrEmpty($token)) "Token was empty"
Assert-Test "POST /api/auth/login returns correct username" ($loginRes.username -eq "admin")

$headers = @{ Authorization = "Bearer $token" }

# Test user registration
$regUser = "user_" + (Get-Random -Minimum 10000 -Maximum 99999)
$regBody = @{ username = $regUser; password = "Password123!"; role = "User" } | ConvertTo-Json
$regRes = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method POST -Body $regBody -ContentType "application/json"
Assert-Test "POST /api/auth/register creates new user & returns token" (![string]::IsNullOrEmpty($regRes.token))

# Test duplicate registration rejection
$statusDupReg = Request-Status -Uri "$baseUrl/api/auth/register" -Method POST -Body $regBody
Assert-Test "POST /api/auth/register rejects duplicate username with 400" ($statusDupReg -eq 400) "Got status $statusDupReg"

# ---------------------------------------------------------
# 3. DTO INPUT VALIDATION TESTS
# ---------------------------------------------------------
Write-Host ""
Write-Host "--- 3. Testing DTO Payload Data Validation ---" -ForegroundColor Yellow

# Missing name & bad email
$invalidDto = @{ name = ""; email = "not-an-email"; department = "IT"; role = "Dev"; salary = -100 } | ConvertTo-Json
$statusInvalidDto = Request-Status -Uri "$baseUrl/api/employees" -Method POST -Headers $headers -Body $invalidDto
Assert-Test "POST /api/employees rejects invalid DTO validation with 400 Bad Request" ($statusInvalidDto -eq 400) "Got status $statusInvalidDto"

# ---------------------------------------------------------
# 4. EMPLOYEE CRUD LIFECYCLE TESTS
# ---------------------------------------------------------
Write-Host ""
Write-Host "--- 4. Testing Employee CRUD Operations ---" -ForegroundColor Yellow

# GET All
$employees = Invoke-RestMethod -Uri "$baseUrl/api/employees" -Headers $headers
Assert-Test "GET /api/employees retrieves employee list" ($employees.Count -ge 5) "Employee count: $($employees.Count)"

# GET By ID
$emp1 = Invoke-RestMethod -Uri "$baseUrl/api/employees/1" -Headers $headers
Assert-Test "GET /api/employees/1 retrieves Employee #1" ($emp1.id -eq 1 -and $emp1.name -eq "Dev Gokha")

# GET Non-Existent ID
$statusNotFound = Request-Status -Uri "$baseUrl/api/employees/99999" -Headers $headers
Assert-Test "GET /api/employees/99999 returns 404 Not Found" ($statusNotFound -eq 404) "Got status $statusNotFound"

# POST Create New Employee
$newEmpDto = @{
    name = "Integration Test Employee"
    email = "test.employee@company.com"
    department = "Quality Assurance"
    role = "Lead QA Automation"
    salary = 85000
    isActive = $true
} | ConvertTo-Json

$createdEmp = Invoke-RestMethod -Uri "$baseUrl/api/employees" -Method POST -Headers $headers -Body $newEmpDto -ContentType "application/json"
$newId = $createdEmp.id
Assert-Test "POST /api/employees creates employee with ID #$newId" ($newId -gt 0 -and $createdEmp.name -eq "Integration Test Employee")

# PUT Update Employee
$updateEmpDto = @{
    name = "Integration Test Employee (Updated)"
    email = "test.employee.updated@company.com"
    department = "Quality Assurance"
    role = "Principal QA Engineer"
    salary = 92000
    isActive = $true
} | ConvertTo-Json

$statusPut = Request-Status -Uri "$baseUrl/api/employees/$newId" -Method PUT -Headers $headers -Body $updateEmpDto
Assert-Test "PUT /api/employees/$newId updates employee (204 No Content)" ($statusPut -eq 204) "Got status $statusPut"

# Verify Updated Data
$updatedEmp = Invoke-RestMethod -Uri "$baseUrl/api/employees/$newId" -Headers $headers
Assert-Test "Verified PUT update persisted correctly in database" ($updatedEmp.salary -eq 92000 -and $updatedEmp.role -eq "Principal QA Engineer")

# DELETE Employee
$statusDelEmp = Request-Status -Uri "$baseUrl/api/employees/$newId" -Method DELETE -Headers $headers
Assert-Test "DELETE /api/employees/$newId removes employee (204 No Content)" ($statusDelEmp -eq 204) "Got status $statusDelEmp"

# Verify Deletion
$statusDelCheck = Request-Status -Uri "$baseUrl/api/employees/$newId" -Headers $headers
Assert-Test "Verified deleted employee now returns 404 Not Found" ($statusDelCheck -eq 404) "Got status $statusDelCheck"

# ---------------------------------------------------------
# 5. LINQ FILTERING AND SORTING TESTS
# ---------------------------------------------------------
Write-Host ""
Write-Host "--- 5. Testing LINQ Filtering & Sorting Queries ---" -ForegroundColor Yellow

# Filter by Department
$itEmps = Invoke-RestMethod -Uri "$baseUrl/api/employees?department=IT" -Headers $headers
$allIT = $true
foreach ($e in $itEmps) { if ($e.department -ne "IT") { $allIT = $false } }
Assert-Test "LINQ Filter: department=IT returns only IT employees" ($allIT -and $itEmps.Count -ge 2)

# Filter by Active Status
$activeEmps = Invoke-RestMethod -Uri "$baseUrl/api/employees?active=true" -Headers $headers
$allActive = $true
foreach ($e in $activeEmps) { if ($e.isActive -ne $true) { $allActive = $false } }
Assert-Test "LINQ Filter: active=true returns only active employees" ($allActive)

# Sort by Salary Descending
$sortedSalaryDesc = Invoke-RestMethod -Uri "$baseUrl/api/employees?sortBy=salary_desc" -Headers $headers
$isSortedDesc = $true
for ($i = 0; $i -lt $sortedSalaryDesc.Count - 1; $i++) {
    if ($sortedSalaryDesc[$i].salary -lt $sortedSalaryDesc[$i+1].salary) {
        $isSortedDesc = $false
    }
}
Assert-Test "LINQ Sort: sortBy=salary_desc returns items sorted high to low" ($isSortedDesc)

# Sort by Name (A-Z)
$sortedName = Invoke-RestMethod -Uri "$baseUrl/api/employees?sortBy=name" -Headers $headers
$isSortedName = $true
for ($i = 0; $i -lt $sortedName.Count - 1; $i++) {
    if ([string]::Compare($sortedName[$i].name, $sortedName[$i+1].name) -gt 0) {
        $isSortedName = $false
    }
}
Assert-Test "LINQ Sort: sortBy=name returns items sorted alphabetically A-Z" ($isSortedName)

# ---------------------------------------------------------
# SUMMARY REPORT
# ---------------------------------------------------------
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Total Passed: $passed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Total Failed: $failed" -ForegroundColor Red
} else {
    Write-Host "  Total Failed: $failed" -ForegroundColor Green
}
Write-Host "==========================================================" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host " ALL SYSTEM TESTS PASSED SUCCESSFULLY!" -ForegroundColor Green
    exit 0
} else {
    Write-Host " SOME TESTS FAILED." -ForegroundColor Red
    exit 1
}
