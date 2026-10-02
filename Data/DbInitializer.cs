using EmployeeManagementApi.Models;
using EmployeeManagementApi.Services;
using Microsoft.EntityFrameworkCore;

namespace EmployeeManagementApi.Data
{
    public static class DbInitializer
    {
        public static void Initialize(ApplicationDbContext context)
        {
            context.Database.EnsureCreated();

            if (!context.Users.Any())
            {
                var adminUser = new User
                {
                    Username = "admin",
                    PasswordHash = AuthService.HashPassword("AdminPassword123!"),
                    Role = "Admin",
                    CreatedAt = DateTime.UtcNow
                };

                var demoUser = new User
                {
                    Username = "dev",
                    PasswordHash = AuthService.HashPassword("DevPassword123!"),
                    Role = "User",
                    CreatedAt = DateTime.UtcNow
                };

                context.Users.AddRange(adminUser, demoUser);
            }

            if (!context.Employees.Any())
            {
                var employees = new[]
                {
                    new Employee { Name = "Dev Gokha", Email = "dev@example.com", Department = "IT", Role = "Senior Developer", Salary = 75000, IsActive = true },
                    new Employee { Name = "Aman Kumar", Email = "aman@example.com", Department = "HR", Role = "Analyst", Salary = 45000, IsActive = true },
                    new Employee { Name = "Sarah Jenkins", Email = "sarah@example.com", Department = "IT", Role = "DevOps Engineer", Salary = 80000, IsActive = true },
                    new Employee { Name = "Michael Scott", Email = "michael@example.com", Department = "Sales", Role = "Regional Manager", Salary = 65000, IsActive = true },
                    new Employee { Name = "Pam Beesly", Email = "pam@example.com", Department = "Admin", Role = "Office Administrator", Salary = 42000, IsActive = false }
                };

                context.Employees.AddRange(employees);
            }

            context.SaveChanges();
        }
    }
}
