using System.Reflection;
using BE.Controllers;
using BE.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Npgsql;

namespace BETest;

public class ReservasTest
{
    [SetUp]
    public void Setup()
    {
    }
    // Retrieving reservations for a specific schedule with valid input returns a successful response with the expected data.
    [Test]
    public void test_retrieve_reservations_valid_input()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "expected result";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(expectedResult);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.GetReservasHorario(123);

        // Assert
        Assert.IsInstanceOf<ContentResult>(result);
        Assert.AreEqual(expectedResult, ((ContentResult)result).Content);
    }

    // Making new reservations with valid input returns a successful response with a unique reservation ID.
    [Test]
    public void test_make_new_reservations_valid_input()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "unique reservation ID";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(expectedResult);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.ReservaHorario(new InputParamsReserva
        {
            reservas = new List<Reserva>
        {
            new Reserva { id_horario = 123, asiento = "A1" },
            new Reserva { id_horario = 123, asiento = "A2" }
        }
        });

        // Assert
        Assert.IsInstanceOf<OkObjectResult>(result);
        Assert.AreEqual(expectedResult, ((OkObjectResult)result).Value);
    }

    // Making new reservations with multiple valid inputs returns a successful response with a unique reservation ID.
    [Test]
    public void test_make_new_reservations_multiple_valid_inputs()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "unique reservation ID";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(expectedResult);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.ReservaHorario(new InputParamsReserva
        {
            reservas = new List<Reserva>
        {
            new Reserva { id_horario = 123, asiento = "A1" },
            new Reserva { id_horario = 123, asiento = "A2" },
            new Reserva { id_horario = 456, asiento = "B1" }
        }
        });

        // Assert
        Assert.IsInstanceOf<OkObjectResult>(result);
        Assert.AreEqual(expectedResult, ((OkObjectResult)result).Value);
    }

    // Retrieving reservations for a non-existent schedule returns a BadRequest response with an error message.
    [Test]
    public void test_retrieve_reservations_nonexistent_schedule()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "Error message";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(null);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.GetReservasHorario(123);

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual(expectedResult, ((BadRequestObjectResult)result).Value);
    }

    // Making new reservations with an empty request body returns a BadRequest response with an error message.
    [Test]
    public void test_make_new_reservations_empty_request_body()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "Error message";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(null);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.ReservaHorario(new InputParamsReserva());

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual(expectedResult, ((BadRequestObjectResult)result).Value);
    }

    // Making new reservations with a request body that contains no reservations returns a BadRequest response with an error message.
    [Test]
    public void test_make_new_reservations_no_reservations()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ReservasController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var expectedResult = "Error message";

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        commandMock.Setup(x => x.ExecuteScalar()).Returns(null);

        var controller = new ReservasController(loggerMock.Object);
        controller.GetType().GetField("_connection_DBSys", BindingFlags.NonPublic | BindingFlags.Instance).SetValue(controller, connectionMock.Object);

        // Act
        var result = controller.ReservaHorario(new InputParamsReserva { reservas = new List<Reserva>() });

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual(expectedResult, ((BadRequestObjectResult)result).Value);
    }

}
