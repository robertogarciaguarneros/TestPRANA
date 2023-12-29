
# Test Prana (Prueba de sistema de venta de boletos)

Sistema que emula la venta de boletos, consta de una API y FrontEnd, esta relizada con .NET Core 6 y una BD Postgresql, esta configuarada para desplegarse en AWS Lambda

## Variables de entorno


BE (API de Backend)
```bash
"ASPNETCORE_ENVIRONMENT": "Development"  (Ambiente de despliegue de la aplicación, puede ser Development o Production)

"DBConn":"User ID=postgres;Password=password;Host=host;Port=5432;Database=Prana;Pooling=true;Connection Lifetime=0;" (Cadena de conexión a la base de datos)
```
FE (FrontEnd)
```bash
"ASPNETCORE_ENVIRONMENT": "Development"   (Ambiente de despliegue de la aplicación, puede ser Development o Production)

"API_BE":"https://localhost/"             (Cadena de conexión a la base de datos)

"pathpre":"/",                            (Path adicional en la ruta de la API, se utiliza por la configurción de AWS, en local basta con el simbolo "/")

"SyncFusionLicence":"xxxxxxxxxxxxxxxxxxxxxxxxxx"   (Licencia de componente Synfusion)
```
## Authors

- [@robertogarciaguarneros](https://www.github.com/robertogarciaguarneros)

