Prueba de sistema de venta de boletos

Variables de entorno necesarias por proyecto

********BE (API de Backend)
        "ASPNETCORE_ENVIRONMENT": "Development"  (Ambiente de despliegue de la aplicación, puede ser Development o Production)
        "DBConn":"User ID=postgres;Password=password;Host=host;Port=5432;Database=Prana;Pooling=true;Connection Lifetime=0;" (Cadena de conexión a la base de datos)

********FE (FrontEnd)
        "ASPNETCORE_ENVIRONMENT": "Development"   (Ambiente de despliegue de la aplicación, puede ser Development o Production)
        "API_BE":"https://localhost/"             (Cadena de conexión a la base de datos)
        "pathpre":"/",                            (Path adicional en la ruta de la API, se utiliza por la configurción de AWS, en local basta con el simbolo "/")
        "SyncFusionLicence":"xxxxxxxxxxxxxxxxxxxxxxxxxx"   (Licencia de componente Synfusion)