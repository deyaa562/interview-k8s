# Stage 1: Build stage with Gradle caching
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /app

# Leverage build cache for dependencies
# Cache Gradle wrapper
COPY gradlew .
COPY gradle gradle
RUN ./gradlew --version # Download gradle wrapper if needed, prime cache layer

# Cache dependencies. Only copy build files first.
# Use --mount=type=cache to keep the Gradle cache persistent across builds
COPY build.gradle settings.gradle ./
RUN --mount=type=cache,target=/root/.gradle ./gradlew build --no-daemon --stacktrace -x test dependencies || exit 0

# Copy the source code
# Use --mount=type=bind for potentially faster context mounting (read-only is safer if applicable)
COPY . .

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew build --no-daemon --stacktrace

# Stage 2: Runtime stage with JRE only
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Create a non-root user and group
RUN groupadd --system --gid 1001 appgroup && \
    useradd --system --uid 1001 --gid appgroup appuser

# Copy only the built JAR from the builder stage
COPY --from=builder --chown=appuser:appgroup /app/build/libs/*.jar app.jar

# Switch to non-root user
USER appuser

EXPOSE 8080

# Set the entrypoint
ENTRYPOINT ["java", "-Dserver.address=0.0.0.0", "-jar", "app.jar"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1