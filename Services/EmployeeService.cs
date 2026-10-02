using EmployeeManagementApi.Data;
using EmployeeManagementApi.DTOs;
using EmployeeManagementApi.Models;
using Microsoft.EntityFrameworkCore;

namespace EmployeeManagementApi.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly ApplicationDbContext _context;

        public EmployeeService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<EmployeeDto>> GetAllAsync(string? department = null, bool? isActive = null, string? sortBy = null)
        {
            // LINQ queryable pipeline using deferred execution
            IQueryable<Employee> query = _context.Employees.AsNoTracking();

            // LINQ filtering with Where
            if (!string.IsNullOrWhiteSpace(department))
            {
                query = query.Where(e => e.Department.ToLower() == department.ToLower());
            }

            if (isActive.HasValue)
            {
                query = query.Where(e => e.IsActive == isActive.Value);
            }

            // LINQ sorting
            query = sortBy?.ToLower() switch
            {
                "salary_desc" => query.OrderByDescending(e => (double)e.Salary),
                "salary_asc" => query.OrderBy(e => (double)e.Salary),
                "name_desc" => query.OrderByDescending(e => e.Name),
                "name" => query.OrderBy(e => e.Name),
                _ => query.OrderByDescending(e => e.Id)
            };

            // LINQ projection with Select and materialization with ToListAsync
            return await query.Select(e => new EmployeeDto
            {
                Id = e.Id,
                Name = e.Name,
                Email = e.Email,
                Department = e.Department,
                Role = e.Role,
                Salary = e.Salary,
                IsActive = e.IsActive,
                CreatedAt = e.CreatedAt
            }).ToListAsync();
        }

        public async Task<EmployeeDto?> GetByIdAsync(int id)
        {
            var employee = await _context.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == id);

            if (employee == null) return null;

            return new EmployeeDto
            {
                Id = employee.Id,
                Name = employee.Name,
                Email = employee.Email,
                Department = employee.Department,
                Role = employee.Role,
                Salary = employee.Salary,
                IsActive = employee.IsActive,
                CreatedAt = employee.CreatedAt
            };
        }

        public async Task<EmployeeDto> CreateAsync(CreateEmployeeDto dto)
        {
            var employee = new Employee
            {
                Name = dto.Name,
                Email = dto.Email,
                Department = dto.Department,
                Role = dto.Role,
                Salary = dto.Salary,
                IsActive = dto.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            _context.Employees.Add(employee);
            await _context.SaveChangesAsync();

            return new EmployeeDto
            {
                Id = employee.Id,
                Name = employee.Name,
                Email = employee.Email,
                Department = employee.Department,
                Role = employee.Role,
                Salary = employee.Salary,
                IsActive = employee.IsActive,
                CreatedAt = employee.CreatedAt
            };
        }

        public async Task<bool> UpdateAsync(int id, UpdateEmployeeDto dto)
        {
            var employee = await _context.Employees.FindAsync(id);
            if (employee == null) return false;

            employee.Name = dto.Name;
            employee.Email = dto.Email;
            employee.Department = dto.Department;
            employee.Role = dto.Role;
            employee.Salary = dto.Salary;
            employee.IsActive = dto.IsActive;

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var employee = await _context.Employees.FindAsync(id);
            if (employee == null) return false;

            _context.Employees.Remove(employee);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
