FROM gradle:jdk11 AS builder
WORKDIR /home/root/build/
COPY . .
RUN ./gradlew build

FROM openjdk:8-jdk-alpine
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
ARG JAR_FILE=target/*.jar
COPY --from=builder /home/root/build/build/libs/gs-spring-boot-docker-0.1.0.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
