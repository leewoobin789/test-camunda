FROM maven:3.8.6-openjdk-11-slim AS build

WORKDIR /tmp/mvn/
COPY src /tmp/build/src
COPY pom.xml /tmp/build
RUN mvn -f /tmp/build/pom.xml clean install -DskipTests

FROM openjdk:11-jre-slim

COPY --from=build /tmp/build/target/consumer-service*.jar /usr/local/bin/consumer-service.jar
WORKDIR /usr/local/bin/

CMD [ "sh", "-c", "java -jar consumer-service.jar"]