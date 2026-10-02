using EmployeeManagementApi.DTOs;
using EmployeeManagementApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EmployeeManagementApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class EmployeesController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public EmployeesController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        /// <summary>
        /// GET /api/employees - Get all employees with optional filtering and sorting
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<EmployeeDto>>> GetAll(
            [FromQuery] string? department,
            [FromQuery] bool? active,
            [FromQuery] string? sortBy)
        {
            var employees = await _employeeService.GetAllAsync(department, active, sortBy);
            return Ok(employees);
        }

        /// <summary>
        /// GET /api/employees/{id} - Get employee by ID
        /// </summary>
        [HttpGet("{id:int}")]
        public async Task<ActionResult<EmployeeDto>> GetById(int id)
        {
            var employee = await _employeeService.GetByIdAsync(id);
            if (employee == null)
            {
                return NotFound(new { message = $"Employee with ID {id} was not found." });
            }

            return Ok(employee);
        }

        /// <summary>
        /// POST /api/employees - Create new employee
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<EmployeeDto>> Create([FromBody] CreateEmployeeDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var created = await _employeeService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        /// <summary>
        /// PUT /api/employees/{id} - Update employee details
        /// </summary>
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateEmployeeDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var success = await _employeeService.UpdateAsync(id, dto);
            if (!success)
            {
                return NotFound(new { message = $"Employee with ID {id} was not found." });
            }

            return NoContent();
        }

        /// <summary>
        /// DELETE /api/employees/{id} - Delete employee by ID
        /// </summary>
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var success = await _employeeService.DeleteAsync(id);
            if (!success)
            {
                return NotFound(new { message = $"Employee with ID {id} was not found." });
            }

            return NoContent();
        }
    }
}
