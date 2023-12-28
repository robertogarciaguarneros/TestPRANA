using System.ComponentModel.DataAnnotations;
using BE.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json.Linq;
using Npgsql;

namespace BE.Controllers;

/// <summary>
/// The ReservasController class is a controller in a C# ASP.NET Core application that handles HTTP requests related to reservations.
/// </summary>
/// <remarks>
/// It includes methods for retrieving reservations for a specific schedule and for making new reservations.
/// </remarks>
/// <example>
/// <code>
/// // Retrieve reservations for a specific schedule
/// GET /api/Reservas/GetReservasHorario?id_horario=123
///
/// // Make new reservations
/// POST /api/Reservas/ReservaHorario
/// Request Body:
/// {
///   "reservas": [
///     {
///       "id_horario": 123,
///       "asiento": "A1"
///     },
///     {
///       "id_horario": 123,
///       "asiento": "A2"
///     }
///   ]
/// }
/// </code>
/// </example>
/// <seealso cref="ControllerBase" />
[ApiController]
[Route("api/[controller]")]
public class ReservasController : ControllerBase
{
    private readonly ILogger<ReservasController> _logger;
    private NpgsqlConnection _connection_DBSys;

    public ReservasController(ILogger<ReservasController> logger)
    {
        _logger = logger;
        _connection_DBSys = new NpgsqlConnection(Environment.GetEnvironmentVariable("DBConn"));
    }

    [HttpGet("GetReservasHorario")]
    public IActionResult GetReservasHorario([Required] int id_horario)
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_reservas_horario", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_id_horario", NpgsqlTypes.NpgsqlDbType.Integer, id_horario);
                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar reservas de horario {id_horario}: Empty response from DB");
                        return BadRequest($"Error al consultar reservas de horario {id_horario}: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar reservas de horario {id_horario}: {ex.Message}");
            return BadRequest($"Error al consultar reservas de horario {id_horario}: {ex.Message}");
        }
    }

    [HttpPost("ReservaHorario")]
    public IActionResult ReservaHorario([FromBody] InputParamsReserva inputs)
    {
        try
        {
            if (inputs.reservas != null)
            {
                if (inputs.reservas.Count > 0)
                {
                    using (_connection_DBSys)
                    {
                        string num_res = Guid.NewGuid().ToString();
                        _connection_DBSys.Open();
                        foreach (var itm in inputs.reservas)
                        {
                            using (var cmd = new NpgsqlCommand("sp_add_reserva", _connection_DBSys))
                            {
                                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                                cmd.Parameters.AddWithValue("@p_id_horario", NpgsqlTypes.NpgsqlDbType.Integer, itm.id_horario);
                                cmd.Parameters.AddWithValue("@p_asiento", NpgsqlTypes.NpgsqlDbType.Varchar, itm.asiento);
                                cmd.Parameters.AddWithValue("@p_id_reserva", NpgsqlTypes.NpgsqlDbType.Varchar, num_res);
                                var rep = cmd.ExecuteScalar();

                                if (rep != null)
                                {
                                    JToken jToken = JToken.Parse(rep.ToString());
                                    if (!string.IsNullOrEmpty(jToken["error"]?.ToString()))
                                        return BadRequest($"Error al guardar boleto {itm.asiento}: " + jToken["error"]?.ToString());
                                }
                                else
                                {
                                    _logger.LogError($"Error al guardar boletos: Empty response from DB");
                                    return BadRequest($"Error al guardar boletos: Empty response from DB");
                                }
                            }
                        }
                        return Ok(num_res);
                    }
                }
                else
                {
                    return BadRequest($"Debes ingresal al menos una reserva");
                }
            }
            else
            {
                return BadRequest($"Debes ingresal al menos una reserva");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al reservar boletos: {ex.Message}");
            return BadRequest($"Error al reservar boletos: {ex.Message}");
        }
    }

}
