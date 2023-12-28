using Microsoft.AspNetCore.Mvc;

namespace FE.Models;

public class MovieViewModel
{
    public int id_pelicula { get; set; }
    public string nombre { get; set; }
    public string sinopsis { get; set; }
    public string url_foto { get; set; }
    public int duracion { get; set; }
    public string director { get; set; }
    public string clasificacion { get; set; }
    public List<ActoresModel> actores { get; set; }
    public List<HorariosModel> horarios { get; set; }
}

public class ActoresModel
{
    public int id { get; set; }
    public string nombre { get; set; }
}

public class HorariosModel
{
    public int id { get; set; }
    public int id_sala { get; set; }
    public DateTime ini { get; set; }
    public DateTime fin { get; set; }
    public double costo { get; set; }
    public string sala { get; set; }
}

