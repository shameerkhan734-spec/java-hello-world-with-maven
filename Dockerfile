# Stage 1: Build
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .

# Fix SSL + certificates
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates

# Force TLS 1.2
RUN mvn -Dmaven.wagon.http.ssl.insecure=true \
        -Dmaven.wagon.http.ssl.allowall=true \
        -Dhttps.protocols=TLSv1.2 \
        clean package -DskipTests

# Stage 2: Run
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

CMD ["java", "-jar", "app.jar"]
