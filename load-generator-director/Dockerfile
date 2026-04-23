FROM amazoncorretto:11

WORKDIR /opt/limbo

COPY httploadgenerator.jar ./httploadgenerator.jar
COPY director-start.sh ./director-start.sh
COPY request-scripts ./request-scripts
COPY workloads ./workloads

RUN chmod +x ./director-start.sh \
    && mkdir -p ./results

CMD ["java", "-jar", "/opt/limbo/httploadgenerator.jar", "loadgenerator"]
