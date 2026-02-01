using Microsoft.AspNetCore.Mvc;

namespace PCM.Backend.Simple.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { 
            status = "OK",
            message = "PCM Backend is running!",
            timestamp = DateTime.UtcNow,
            version = "1.0.0"
        });
    }

    [HttpGet("test")]
    public IActionResult Test()
    {
        return Ok(new { 
            message = "Test endpoint working!",
            data = new {
                members = 5,
                courts = 4,
                tournaments = 2
            }
        });
    }
}