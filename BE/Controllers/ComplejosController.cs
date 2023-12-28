using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace BE.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ComplejosController : ControllerBase
{
    private readonly ILogger<ComplejosController> _logger;
    private NpgsqlConnection _connection_DBSys;

    public ComplejosController(ILogger<ComplejosController> logger)
    {
        _logger = logger;
        _connection_DBSys = new NpgsqlConnection(Environment.GetEnvironmentVariable("DBConn"));
    }

    [HttpGet("GetComplejos")]
    public IActionResult GetComplejos()
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_complejos", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar complejos: Empty response from DB");
                        return BadRequest($"Error al consultar complejos: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar complejos: {ex.Message}");
            return BadRequest($"Error al consultar complejos: {ex.Message}");
        }
    }

}