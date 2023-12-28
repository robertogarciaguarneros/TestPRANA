using BE.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using Npgsql;

namespace BETest;

public class ComplejosTests
{
    [SetUp]
    public void Setup()
    {
    }

    // Successfully retrieve data from PostgreSQL database using stored procedure and return as JSON response
    [Test]
    public void test_retrieve_data_from_database()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var complejosController = new ComplejosController(loggerMock.Object);

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        connectionMock.Setup(x => x.CreateCommand()).Returns(commandMock.Object);
        commandMock.Setup(x => x.ExecuteScalar()).Returns("data");

        // Act
        var result = complejosController.GetComplejos();

        // Assert
        Assert.IsInstanceOf<ContentResult>(result);
        Assert.AreEqual("data", ((ContentResult)result).Content);
        Assert.AreEqual("application/json", ((ContentResult)result).ContentType);
    }

    // Handle and log errors that occur during retrieval of data from database and return appropriate error response
    [Test]
    public void test_handle_and_log_errors()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var complejosController = new ComplejosController(loggerMock.Object);

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        connectionMock.Setup(x => x.CreateCommand()).Returns(commandMock.Object);
        commandMock.Setup(x => x.ExecuteScalar()).Throws(new Exception("Error"));

        // Act
        var result = complejosController.GetComplejos();

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual("Error al consultar complejos: Error", ((BadRequestObjectResult)result).Value);
    }

    // Initialize new instance of ComplejosController class with logger instance and PostgreSQL database connection
    [Test]
    public void test_initialize_instance()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();

        // Act
        var complejosController = new ComplejosController(loggerMock.Object);

        // Assert
        Assert.IsNotNull(complejosController);
    }

    // Empty response from database should return BadRequest error response
    [Test]
    public void test_empty_response_from_database()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var complejosController = new ComplejosController(loggerMock.Object);

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        connectionMock.Setup(x => x.CreateCommand()).Returns(commandMock.Object);
        commandMock.Setup(x => x.ExecuteScalar()).Returns(null);

        // Act
        var result = complejosController.GetComplejos();

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual("Error al consultar complejos: Empty response from DB", ((BadRequestObjectResult)result).Value);
    }

    // Exception thrown during retrieval of data from database should return BadRequest error response with appropriate error message
    [Test]
    public void test_exception_during_retrieval()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var complejosController = new ComplejosController(loggerMock.Object);

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        connectionMock.Setup(x => x.CreateCommand()).Returns(commandMock.Object);
        commandMock.Setup(x => x.ExecuteScalar()).Throws(new Exception("Error"));

        // Act
        var result = complejosController.GetComplejos();

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual("Error al consultar complejos: Error", ((BadRequestObjectResult)result).Value);
    }

    // Invalid stored procedure name should throw exception and return BadRequest error response with appropriate error message
    [Test]
    public void test_invalid_stored_procedure_name()
    {
        // Arrange
        var loggerMock = new Mock<ILogger<ComplejosController>>();
        var connectionMock = new Mock<NpgsqlConnection>();
        var commandMock = new Mock<NpgsqlCommand>();
        var complejosController = new ComplejosController(loggerMock.Object);

        loggerMock.Setup(x => x.LogError(It.IsAny<string>()));
        connectionMock.Setup(x => x.Open());
        connectionMock.Setup(x => x.CreateCommand()).Returns(commandMock.Object);
        commandMock.Setup(x => x.ExecuteScalar()).Throws(new Exception("Invalid stored procedure name"));

        // Act
        var result = complejosController.GetComplejos();

        // Assert
        Assert.IsInstanceOf<BadRequestObjectResult>(result);
        Assert.AreEqual("Error al consultar complejos: Invalid stored procedure name", ((BadRequestObjectResult)result).Value);
    }

}