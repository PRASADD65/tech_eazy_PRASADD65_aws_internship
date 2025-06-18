# Stage 1: Build the application
# Using a JDK image for compilation
FROM openjdk:21-jdk-slim AS build

# Install necessary tools for building (Maven, Git, Node.js)
# Combine RUN commands to reduce image layers and clean up afterward
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        maven \
        git \
        ca-certificates \
        curl \
        gnupg && \
    # Setup Node.js (v20 LTS, as per your original script)
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    # Clean up apt cache to keep image size small
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container for the build stage
WORKDIR /app

# Copy your local project files into the image for building
COPY pom.xml ./
COPY src ./src/

# Build the Spring Boot application using Maven
RUN mvn clean install -DskipTests

# Stage 2: Create the final production image
# TEMPORARY WORKAROUND: Using the JDK image for the runtime stage as JRE images are failing.
# This will result in a larger final image.
FROM openjdk:21-jdk-slim

# Define arguments for application artifact ID and version
ARG APP_ARTIFACT_ID="techeazy-devops"
ARG APP_VERSION="0.0.1-SNAPSHOT"

# Copy the built JAR from the 'build' stage into the final image
COPY --from=build /app/target/${APP_ARTIFACT_ID}-${APP_VERSION}.jar /app/app.jar

# Define the port your Spring Boot application listens on (default for Spring Boot is 8080)
EXPOSE 8080

# Command to run the application when the container starts
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
