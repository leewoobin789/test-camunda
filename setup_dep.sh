#!/bin/bash

#Parameters
ClUSTER_NAME="${1:-camunda-sandbox}"
NAMESPACE="${2:-demo}"
DO_DEPLOY="${3:-false}"

#Constants
KAFKA_CLUSTER_NAME="demo"

INCOMING_TOPIC="com.topic.in"
OUTGOING_TOPIC="com.topic.out"

CONSUMER_SERVICE="consumer-service"
PRODUCER_SERVICE="producer-service"

get_service_dir() {
    # $1: service name
    echo "$(cd apps/$1 && pwd)"
}

setup_kafka_cluster() {
    echo "Check existence of kafka helm repo"
    KAFKA_REPO_EXISTENCE=$(helm repo list | grep "https://confluentinc.github.io/cp-helm-charts")

    if [ -z "${KAFKA_REPO_EXISTENCE}" ]; then 
        echo "kafka helm chart repo is being added"
        helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
    fi

    echo "Kafka cluster is being deployed"
    helm install --set cp-schema-registry.enabled=true,cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false,cp-ksql-server.enabled=false $KAFKA_CLUSTER_NAME confluentinc/cp-helm-charts || true
}

wait_for_Kafka() {
    echo "Waiting for kafka cluster to be deployed successfully"
    kubectl wait --for=condition=available --timeout=300s deployment/$KAFKA_CLUSTER_NAME-cp-control-center # to prevent topic to be generated before consumer deployed
    declare -a num=("0" "1" "2")
    for i in "${num[@]}"
    do
        kubectl wait --for=condition=ready --timeout=100s pod/$KAFKA_CLUSTER_NAME-cp-kafka-${i}
        kubectl wait --for=condition=ready --timeout=100s pod/$KAFKA_CLUSTER_NAME-cp-zookeeper-${i}
    done
}

create_topic() {
    sleep 20
    TOPIC=$1
    echo "Topic($TOPIC) is being created"
    kubectl exec -c cp-kafka-broker -it $KAFKA_CLUSTER_NAME-cp-kafka-0 -- /bin/bash /usr/bin/kafka-topics --create --zookeeper $KAFKA_CLUSTER_NAME-cp-zookeeper:2181 --topic $TOPIC --partitions 3 --replication-factor 1
}

delete() {
    # $1: service name
    SERVICE=$1
    DIR=$(get_service_dir "$1")

    kubectl kustomize $DIR/k8s | kubectl delete -f -
}

build() {
    # $1: service name
    SERVICE=$1
    DIR=$(get_service_dir "$1")
    echo "build $SERVICE"
    docker rm -f ${SERVICE}
    docker rmi $(docker images | grep "${SERVICE}") || true
    docker build ${DIR}/. -t ${SERVICE}
    kind load docker-image --name ${ClUSTER_NAME} ${SERVICE}
}

deploy() {
    # $1: service name, $2: bootstrap, $3: topic name 
    echo "deploy customer service"
    DIR=$(get_service_dir "$1")
    gsed -e "s,VALUE_KAFKA_BOOTSTRAP,$2,g" -e "s,VALUE_KAFKA_TOPIC,$3,g" $DIR/k8s/deployment.yml.template > $DIR/k8s/deployment.yml
    
    kubectl kustomize $DIR/k8s | kubectl apply -f -
}

if [ "$DO_DEPLOY" = true ]; then
    delete "$CONSUMER_SERVICE"
    delete "$PRODUCER_SERVICE"

    build "$CONSUMER_SERVICE"
    build "$PRODUCER_SERVICE"

    deploy "$CONSUMER_SERVICE" "$KAFKA_CLUSTER_NAME-cp-kafka:9092" "$OUTGOING_TOPIC"
    deploy "$PRODUCER_SERVICE" "$KAFKA_CLUSTER_NAME-cp-kafka:9092" "$INCOMING_TOPIC"
else
    helm repo update
    setup_kafka_cluster

    CONSUMER_EXISTENCE="$(kubectl get deployment --no-headers -o custom-columns=":metadata.name" | grep "$CONSUMER_SERVICE")"
    if [ -z "${CONSUMER_EXISTENCE}" ]; then
        wait_for_Kafka
        create_topic "$INCOMING_TOPIC"
        create_topic "$OUTGOING_TOPIC"
    fi
fi

echo "finished"