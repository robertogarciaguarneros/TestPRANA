using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace BE.Controllers;

/// <summary>
/// The <c>MoviesController</c> class is a controller in a C# ASP.NET Core application that handles HTTP requests related to movies.
/// It provides methods to retrieve movies based on the provided complex ID, date, and movie ID.
/// The class also handles exceptions and logs error messages.
/// </summary>
/// <example>
/// <code>
/// MoviesController moviesController = new MoviesController(logger);
/// IActionResult result = moviesController.GetMovies(1);
/// </code>
/// </example>
/// <remarks>
/// Main functionalities:
/// - Retrieve movies based on the provided complex ID
/// - Retrieve movies based on the provided complex ID and date
/// - Retrieve the details of a movie based on the provided movie ID, complex ID, and date
/// </remarks>
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

    /// <summary>
    /// Retrieves movies based on the provided complex ID.
    /// </summary>
    /// <param name="id_complejo">The complex ID.</param>
    /// <returns>The movies associated with the complex ID in JSON format.</returns>
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

    /// <summary>
    /// Retrieves movies based on the provided complex ID and date.
    /// </summary>
    /// <param name="id_complejo">The complex ID.</param>
    /// <param name="fec">The date.</param>
    /// <returns>The movies associated with the complex ID and date in JSON format.</returns>
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

    /// <summary>
    /// Retrieves the details of a movie based on the provided movie ID, complex ID, and date.
    /// </summary>
    /// <param name="id_movie">The movie ID.</param>
    /// <param name="id_complejo">The complex ID.</param>
    /// <param name="fec">The date.</param>
    /// <returns>The details of the movie associated with the movie ID, complex ID, and date in JSON format.</returns>
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