using System.ComponentModel.DataAnnotations;

namespace EmployeeManagementApi.DTOs
{
    public class CreateEmployeeDto
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Department is required")]
        public string Department { get; set; } = string.Empty;

        [Required(ErrorMessage = "Role is required")]
        public string Role { get; set; } = string.Empty;

        [Range(0, 10000000, ErrorMessage = "Salary must be a positive value")]
        public decimal Salary { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
