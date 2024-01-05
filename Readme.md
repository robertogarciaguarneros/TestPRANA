
# Test Prana (Prueba de sistema de venta de boletos)

Sistema que emula la venta de boletos, consta de una API y FrontEnd, está realizada con .NET Core 6 MVC y una BD Postgresql, está configurada para desplegarse en AWS Lambda.

Para el FrontEnd adicionalmente se usan JS, CSS y Syncfusion.

## Variables de entorno


BE (API de Backend)
```bash
"ASPNETCORE_ENVIRONMENT": "Development"  (Ambiente de despliegue de la aplicación, puede ser Development o Production)

"DBConn":"User ID=postgres;Password=password;Host=host;Port=5432;Database=Prana;Pooling=true;Connection Lifetime=0;" (Cadena de conexión a la base de datos)
```
FE (FrontEnd)
```bash
"ASPNETCORE_ENVIRONMENT": "Development"   (Ambiente de despliegue de la aplicación, puede ser Development o Production)

"API_BE":"https://localhost/"             (URL de la API que proporciona información)

"pathpre":"/"                             (Path adicional en la ruta de la API, se utiliza por la configuración de AWS, en local basta con el símbolo "/")

"SyncFusionLicence":"xxxxxxxxxxxxxxxxxxxxxxxxxx"   (Licencia de componente Syncfusion)
```

## Base de datos

Se encuentra el script inicial en la carpeta ScriptsBD, con esta se puede generar la BD inicial necesaria para el funcionamiento de la plataforma, está creado para se ejecutado en una BD Postgres.

## URLS de prueba

BE ==> https://n4r3y4yhkb.execute-api.us-west-1.amazonaws.com/Prod/swagger/index.html

FE ==> https://prf1rn4kgc.execute-api.us-west-1.amazonaws.com/Prod

## Authors

- [@robertogarciaguarneros](https://www.github.com/robertogarciaguarneros)

