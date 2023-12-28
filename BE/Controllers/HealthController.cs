using Microsoft.AspNetCore.Mvc;

namespace BE.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{

    [HttpGet(Name = "Check")]
    public async Task<IActionResult> Check()
    {
        return Ok();
    }
}
