# Etapa de construcción de la app
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package

FROM openjdk:17-slim

WORKDIR /app

# Instala curl y bash (necesarios para el script)
RUN apt-get update && apt-get install -y curl bash

# Copia el .jar desde la etapa anterior
COPY --from=build /app/target/*.jar app.jar

# Exponer puertos de la app
EXPOSE 6060 9090

# Comando para iniciar la app
CMD [ "java", "-jar", "app.jar" ]

