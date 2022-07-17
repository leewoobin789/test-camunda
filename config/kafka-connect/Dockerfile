FROM confluentinc/cp-kafka-connect:6.1.0

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"

COPY com.topic.in_sink.json ./config/kafka-connect/
COPY com.topic.out_source.json ./config/kafka-connect/

RUN confluent-hub install --no-prompt camunda/kafka-connect-zeebe:0.40.0