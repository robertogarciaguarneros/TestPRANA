using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace BE.Controllers;

/// <summary>
/// The <c>MoviesController</c> class is a controller in a C# ASP.NET Core application that handles HTTP requests related to movies. 
/// It connects to a PostgreSQL database and performs various operations such as retrieving movies, retrieving movies by date, and retrieving movie details.
/// </summary>
/// <example>
/// <code>
/// // Create an instance of the MoviesController class
/// var moviesController = new MoviesController(logger);
///
/// // Get movies by complex ID
/// var result1 = moviesController.GetMovies(1);
///
/// // Get movies by complex ID and date
/// var result2 = moviesController.GetMoviesFec(1, DateTime.Now);
///
/// // Get movie details by movie ID, complex ID, and date
/// var result3 = moviesController.GetMovieDetail(1, 1, DateTime.Now);
/// </code>
/// </example>
/// <remarks>
/// Main functionalities:
/// - Connects to a PostgreSQL database using the provided connection string
/// - Retrieves movies from the database based on complex ID
/// - Retrieves movies from the database based on complex ID and date
/// - Retrieves movie details from the database based on movie ID, complex ID, and date
/// </remarks>
/// <seealso cref="ControllerBase"/>
[ApiController]
[Route("api/[controller]")]
public class MoviesController : ControllerBase
{
    private readonly ILogger<MoviesController> _logger;
    private NpgsqlConnection _connection_DBSys;

    public MoviesController(ILogger<MoviesController> logger)
    {
        _logger = logger;
        _connection_DBSys = new NpgsqlConnection(Environment.GetEnvironmentVariable("DBConn"));
    }

    [HttpGet("GetMovies")]
    public IActionResult GetMovies([Required] int id_complejo)
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_movies", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_id_complejo", NpgsqlTypes.NpgsqlDbType.Integer, id_complejo);
                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar peliculas del complejo {id_complejo}: Empty response from DB");
                        return BadRequest($"Error al consultar peliculas del complejo {id_complejo}: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar peliculas del complejo {id_complejo}: {ex.Message}");
            return BadRequest($"Error al consultar peliculas del complejo {id_complejo}: {ex.Message}");
        }
    }
    [HttpGet("GetMoviesFec")]
    public IActionResult GetMoviesFec([Required] int id_complejo, [Required] DateTime fec)
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_movies", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_id_complejo", NpgsqlTypes.NpgsqlDbType.Integer, id_complejo);
                    cmd.Parameters.AddWithValue("@p_fec", NpgsqlTypes.NpgsqlDbType.Timestamp, fec);
                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar peliculas del complejo {id_complejo}: Empty response from DB");
                        return BadRequest($"Error al consultar peliculas del complejo {id_complejo}: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar peliculas del complejo {id_complejo}: {ex.Message}");
            return BadRequest($"Error al consultar peliculas del complejo {id_complejo}: {ex.Message}");
        }
    }

    [HttpGet("GetMovieDetail")]
    public IActionResult GetMovieDetail([Required] int id_movie, [Required] int id_complejo, [Required] DateTime fec)
    {
        try
        {
            using (_connection_DBSys)
            {
                _connection_DBSys.Open();
                using (var cmd = new NpgsqlCommand("sp_get_movie_detail", _connection_DBSys))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@p_id_movie", NpgsqlTypes.NpgsqlDbType.Integer, id_movie);
                    cmd.Parameters.AddWithValue("@p_id_complejo", NpgsqlTypes.NpgsqlDbType.Integer, id_complejo);
                    cmd.Parameters.AddWithValue("@p_fec", NpgsqlTypes.NpgsqlDbType.Timestamp, fec);

                    var rep = cmd.ExecuteScalar();

                    if (rep != null)
                    {
                        return Content(rep.ToString(), "application/json");
                    }
                    else
                    {
                        _logger.LogError($"Error al consultar detalle de pelicula {id_movie}: Empty response from DB");
                        return BadRequest($"Error al consultar detalle de pelicula {id_movie}: Empty response from DB");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al consultar detalle de pelicula {id_movie}: {ex.Message}");
            return BadRequest(ex.Message);
        }
    }
}
