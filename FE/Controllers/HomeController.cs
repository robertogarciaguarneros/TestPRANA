using System.Diagnostics;
using System.Text.Json;
using FE.Models;
using Microsoft.AspNetCore.Mvc;
using RestSharp;

namespace FE.Controllers;
/// <summary>
/// The HomeController class is responsible for handling HTTP requests and rendering views related to movies and reservations in a cinema application.
/// </summary>
/// <remarks>
/// This class provides functionalities for retrieving a list of movies and their details, loading views for movie details and ticket purchasing, and handling reservation-related operations such as retrieving seating maps and confirming ticket purchases.
/// </remarks>
/// <example>
/// <code>
/// // Creating an instance of the HomeController class
/// var homeController = new HomeController();
///
/// // Calling the GetMovies method to retrieve a list of movies
/// var movies = await homeController.GetMovies(1, DateTime.Now);
///
/// // Calling the DetalleMovie method to retrieve the details of a movie
/// var movieDetails = await homeController.DetalleMovie(1, 1, "2022-01-01");
///
/// // Calling the Comprar method to load the view for purchasing tickets
/// var compraView = await homeController.Comprar(1, 1, "Movie Title");
///
/// // Calling the GetMapDataSource method to retrieve the data source for a seating map
/// var mapDataSource = await homeController.GetMapDataSource(1, 1);
///
/// // Calling the GetMapData method to retrieve the data for a seating map
/// var mapData = await homeController.GetMapData(1);
///
/// // Calling the ConfirmaVenta method to confirm a ticket purchase
/// var confirmation = await homeController.ConfirmaVenta(1, new List<string>{"A1", "A2"});
/// </code>
/// </example>
/// <seealso cref="GetMovies(int, DateTime)"/>
/// <seealso cref="DetalleMovie(int, int, string)"/>
/// <seealso cref="Comprar(int, int, string)"/>
/// <seealso cref="GetMapDataSource(int, int)"/>
/// <seealso cref="GetMapData(int)"/>
/// <seealso cref="ConfirmaVenta(int, List{string})"/>
public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public async Task<IActionResult> Index()
    {
        HttpClient client = new HttpClient();
        HttpResponseMessage response = await client.GetAsync($"{Environment.GetEnvironmentVariable("API_BE")}Complejos/GetComplejos");
        if (response.IsSuccessStatusCode)
        {
            string res = await response.Content.ReadAsStringAsync();
            var cines = string.IsNullOrEmpty(res) ? new List<ComplejoModel>() : JsonSerializer.Deserialize<IList<ComplejoModel>>(res);

            string ddlOpts = $"<option value=\"\" selected>Selecciona...</option>";

            foreach (var ct in cines)
            {
                ddlOpts += $"<option value=\"{ct.id}\">{ct.nombre}</option>";
            }
            ViewBag.Cines = ddlOpts;
        }
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> GetMovies(int idcomplejo, DateTime v_fec)
    {
        try
        {
            string strres = "";
            HttpClient client = new HttpClient();
            HttpResponseMessage response = await client.GetAsync($"{Environment.GetEnvironmentVariable("API_BE")}Movies/GetMoviesFec?id_complejo={idcomplejo}&fec={v_fec.ToString("yyyy-MM-dd")}");
            if (response.IsSuccessStatusCode)
            {
                string res = await response.Content.ReadAsStringAsync();
                if (!string.IsNullOrEmpty(res))
                {
                    var units = JsonSerializer.Deserialize<IList<MovieModel>>(res);

                    foreach (var ct in units)
                    {
                        strres += $"<div class=\"col-sm-4\">" +
                                    $"<div class=\"card\">" +
                                        $"<img src=\"{ct.url_foto}\" class=\"card-img-top\" alt=\"{ct.nombre}\">" +
                                        $"<div class=\"card-body\">" +
                                            $"<h5 class=\"card-title\">{ct.nombre}</h5>" +
                                            $"<p class=\"card-text text-truncate\">{ct.sinopsis}</p>" +
                                        $"</div>" +
                                        $"<div class=\"card-body\">" +
                                            $"<a href=\"{Environment.GetEnvironmentVariable("pathpre")}Home/DetalleMovie?id={ct.id_pelicula}&id_c={idcomplejo}&fec={v_fec.ToString("yyyy-MM-dd")}\" class=\"card-link\">Detalles...</a>" +
                                        $"</div>" +
                                    $"</div>" +
                                $"</div>";
                    }
                }

                if (string.IsNullOrEmpty(strres))
                {
                    strres = $"Sin información";
                }

                return Json(strres);
            }

            return BadRequest(response.Content);

        }
        catch (Exception ez)
        {
            _logger.LogError($"Error al obtener peliculas: {ez.Message}");
            return BadRequest(ez.Message);
        }
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

    public async Task<IActionResult> DetalleMovie(int id, int id_c, string fec)
    {
        try
        {
            string strres = "";
            HttpClient client = new HttpClient();
            HttpResponseMessage response = await client.GetAsync($"{Environment.GetEnvironmentVariable("API_BE")}Movies/GetMovieDetail?id_movie={id}&id_complejo={id_c}&fec={fec}");
            if (response.IsSuccessStatusCode)
            {
                string res = await response.Content.ReadAsStringAsync();
                if (!string.IsNullOrEmpty(res))
                {
                    var detail = JsonSerializer.Deserialize<IList<MovieViewModel>>(res);
                    if (detail.Count == 1)
                    {
                        return View(detail[0]);
                    }
                    else
                    {
                        return BadRequest("No data found");
                    }
                }
            }
            return View();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al obtener detalle de pelicula: {ex.Message}");
            return BadRequest($"Error al obtener detalle de pelicula: {ex.Message}");
        }
    }

    public async Task<IActionResult> Comprar(int id, int id_c, string titulo)
    {
        try
        {
            ViewBag.id_h = id;
            ViewBag.id_sala = id_c;
            ViewBag.titulo = titulo;
            return View();
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error al cargar vista comprar de horario {id}: {ex.Message}");
            return BadRequest($"Error al cargar vista comprar de horario {id}: {ex.Message}");
        }
    }

    [HttpPost]
    public async Task<IActionResult> GetMapDataSource(int idhorario, int idsala)
    {
        try
        {
            List<string> res = new List<string>();
            string allText = "";
            if (System.IO.File.Exists($"./wwwroot/scripts/MapsData/sala{idsala}.json"))
            {
                allText = System.IO.File.ReadAllText($"./wwwroot/scripts/MapsData/sala{idsala}.json");
            }
            else
            {
                allText = System.IO.File.ReadAllText($"./wwwroot/scripts/MapsData/mapprojectdef.json");
            }

            dynamic objJS = Newtonsoft.Json.Linq.JObject.Parse(allText);
            Dictionary<string, ReservaModel> objVals = new Dictionary<string, ReservaModel>();
            string resJS = "[";
            HttpClient client = new HttpClient();
            HttpResponseMessage response = await client.GetAsync($"{Environment.GetEnvironmentVariable("API_BE")}Reservas/GetReservasHorario?id_horario={idhorario}");
            if (response.IsSuccessStatusCode)
            {
                string res_h = await response.Content.ReadAsStringAsync();
                var reservas = string.IsNullOrEmpty(res_h) ? new List<ReservaModel>() : JsonSerializer.Deserialize<IList<ReservaModel>>(res_h);

                foreach (var r in reservas)
                {
                    objVals.Add(r.id_asiento, r);
                }
            }

            int rn = 1;
            int rn_2 = 0;
            foreach (dynamic nd in objJS.features)
            {
                if (nd.properties.value != null)
                {

                    string id = nd.properties.value;
                    if (id != "Pantalla")
                    {
                        rn_2++;
                    }
                    string status = "Disponible";
                    if (objVals.ContainsKey(id))
                    {
                        status = "Reservado";
                    }
                    resJS += "{";
                    resJS += $"\"name\": \"{id}\",";
                    resJS += $"\"label\": \"{id}\",";
                    resJS += $"\"value\":\"{id}\",";
                    resJS += $"\"tipo\":\"{"A"}\",";
                    resJS += $"\"idi\":{rn},";
                    resJS += $"\"status\":\"{status}\"";
                    resJS += "},";
                    rn++;
                }
            }
            int max_asets = rn_2 - objVals.Count;
            int min_asets = 1;

            if (objVals.Count == max_asets)
            {
                min_asets = 0;
            }

            if (resJS.EndsWith(","))
            {
                resJS = resJS.Substring(0, resJS.Length - 1);
            }
            resJS += "]";
            res.Add(min_asets.ToString());
            res.Add(max_asets.ToString());
            res.Add(resJS);
            return Ok(res);

        }
        catch (Exception ez)
        {
            return BadRequest(ez.Message);
        }
    }

    [HttpPost]
    public async Task<IActionResult> GetMapData(int idsala)
    {
        try
        {
            string allText = "";
            if (System.IO.File.Exists($"./wwwroot/scripts/MapsData/sala{idsala}.json"))
            {
                allText = System.IO.File.ReadAllText($"./wwwroot/scripts/MapsData/sala{idsala}.json");
            }
            else
            {
                allText = System.IO.File.ReadAllText($"./wwwroot/scripts/MapsData/mapprojectdef.json");
            }

            return Ok(allText);
        }
        catch (Exception ez)
        {
            return BadRequest(ez.Message);
        }
    }

    [HttpPost]
    public async Task<IActionResult> ConfirmaVenta(int p_horario, List<string> p_asientos)
    {
        try
        {
            var url = @Environment.GetEnvironmentVariable("API_BE") + "Reservas/ReservaHorario";
            var clientHttp = new RestClient(url);
            var rqClient = new RestRequest();
            rqClient.Method = Method.Post;
            rqClient.AddHeader("accept", "*/*");
            rqClient.AddHeader("content-type", "application/json");

            List<object> resArray = new List<object>();// { result, result1 };
            foreach (var v in p_asientos)
            {
                resArray.Add(new
                {
                    id_horario = p_horario,
                    asiento = v
                });
            }

            rqClient.AddJsonBody(
               new
               {
                   reservas = resArray
               }
            );

            var responseAgents = clientHttp.Execute(rqClient);

            if (responseAgents.StatusCode == System.Net.HttpStatusCode.OK)
            {
                return Ok(responseAgents.Content);
            }
            else
            {
                return BadRequest(responseAgents.Content);
            }


        }
        catch (Exception ez)
        {
            return BadRequest(ez.Message);
        }
    }

}