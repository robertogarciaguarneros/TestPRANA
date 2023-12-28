using Microsoft.AspNetCore.Mvc;

namespace BE.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    /// <summary>
    /// Handles HTTP GET requests to the /api/health/check endpoint.
    /// Returns an HTTP 200 OK response.
    /// </summary>
    /// <returns>An IActionResult representing an HTTP 200 OK response.</returns>
    [HttpGet(Name = "Check")]
    public async Task<IActionResult> Check()
    {
        return Ok();
    }
}
