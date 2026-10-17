# ===== Stage 1: Build the jar =====
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first (only re-downloads when pom.xml changes)
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

# Build the application (skip tests: they need a running database)
COPY src ./src
RUN mvn -q -B clean package -DskipTests

# ===== Stage 2: Run the jar =====
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# The platform injects PORT; prod profile binds server.port to it
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
