using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace BE.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SalasController : ControllerBase
{
    private readonly ILogger<SalasController> _logger;
    private NpgsqlConnection _connection_DBSys;

    public SalasController(ILogger<SalasController> logger)
    {
        _logger = logger;
        _connection_DBSys = new NpgsqlConnection(Environment.GetEnvironmentVariable("DBConn"));
    }
    [HttpGet("GetSalaDetail")]
    public IActionResult GetSalaDetail([Required] int id_sala)
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_sala", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_id_sala", NpgsqlTypes.NpgsqlDbType.Integer, id_sala);
                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar detalle de sala {id_sala}: Empty response from DB");
                        return BadRequest($"Error al consultar detalle de sala {id_sala}: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar detalle de sala {id_sala}: {ex.Message}");
            return BadRequest($"Error al consultar detalle de sala {id_sala}: {ex.Message}");
        }
    }

}
