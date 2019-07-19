FROM openjdk:8u212
MAINTAINER freshchen
VOLUME /tmp
ADD ad-eureka-server-1.0-SNAPSHOT.jar app.jar
RUN bash -c 'touch /app.jar'
EXPOSE 8800
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]