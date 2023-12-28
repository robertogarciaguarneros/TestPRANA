namespace BE.Models
{
    public class InputParamsReserva
    {
        public List<Reserva> reservas { get; set; }
    }

    public class Reserva
    {
        public int id_horario { get; set; }
        public string asiento { get; set; }
    }
}

