FROM openjdk:21
WORKDIR /app
LABEL maintainer="javaguides.net"
COPY target/player-team-cucumber-0.0.1-SNAPSHOT.jar player-team-cucumber.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "player-team-cucumber.jar"]
