#!/bin/bash

#Parameters
ClUSTER_NAME="${1:-camunda-sandbox}"
NAMESPACE="${2:-demo}"
DO_DEPLOY="${3:-false}"

#Constants
DEP_CLUSTER_NAME="demo"

INCOMING_TOPIC="com.topic.in.order_created"
OUTGOING_TOPIC_1="com.topic.out.order_accepted"
OUTGOING_TOPIC=_2"com.topic.out.order_canceled"


CONSUMER_SERVICE="consumer-service"
PRODUCER_SERVICE="producer-service"

CAMUNDA_USERNAME="demo"
CAMUNDA_PASSWORD="demo"

get_service_dir() {
    # $1: service name
    echo "$(cd apps/$1 && pwd)"
}

##### KAKFA SETUP
setup_kafka_cluster() {
    echo "Check existence of kafka helm repo"
    KAFKA_REPO_EXISTENCE=$(helm repo list | grep "https://confluentinc.github.io/cp-helm-charts")

    if [ -z "${KAFKA_REPO_EXISTENCE}" ]; then 
        echo "kafka helm chart repo is being added"
        helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/
    fi

    echo "Kafka cluster is being deployed"
    helm install -f ./config/confluent-value.yaml \
        $DEP_CLUSTER_NAME confluentinc/cp-helm-charts || true
}

wait_for_Kafka() {
    echo "Waiting for kafka cluster to be deployed successfully"
    kubectl wait --for=condition=available --timeout=300s deployment/$DEP_CLUSTER_NAME-cp-control-center # to prevent topic to be generated before consumer deployed
    declare -a num=("0" "1" "2")
    for i in "${num[@]}"
    do
        kubectl wait --for=condition=ready --timeout=120s pod/$DEP_CLUSTER_NAME-cp-kafka-${i}
        kubectl wait --for=condition=ready --timeout=120s pod/$DEP_CLUSTER_NAME-cp-zookeeper-${i}
    done
}

create_topic() {
    TOPIC=$1
    echo "Topic($TOPIC) is being created"
    kubectl exec -c cp-kafka-broker -it $DEP_CLUSTER_NAME-cp-kafka-0 -- /bin/bash /usr/bin/kafka-topics --create --zookeeper $DEP_CLUSTER_NAME-cp-zookeeper:2181 --topic $TOPIC --partitions 3 --replication-factor 1
}

config_connect() {
    #TODO: confluent hub install dependencies
    connect_pod=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep "connect")
    kubectl cp ./config/kafka-connect $connect_pod:config/.
    for file in config/kafka-connect/*.json; do
        [ -f "$file" ] && kubectl exec -it $connect_pod -- curl -X POST -H "Content-Type: application/json" --data @$file http://localhost:8083/connectors
    done
}


##### SERVICE SETUP
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
    gsed -e "s,VALUE_KAFKA_BOOTSTRAP,$2,g" \
        -e "s,VALUE_SCHEMA_REGISTRY_SERVER,$3,g"  \
        -e "s,VALUE_KAFKA_TOPIC,$4,g" \
        $DIR/k8s/deployment.yml.template > $DIR/k8s/deployment.yml
    
    kubectl kustomize $DIR/k8s | kubectl apply -f -
}

##### CAMUNDA SETUP
setup_camunda_cluster() {
    echo "Check existence of camunda helm repo"
    CAMUNDA_REPO_EXISTENCE=$(helm repo list | grep "https://helm.camunda.io")

    if [ -z "${CAMUNDA_REPO_EXISTENCE}" ]; then 
        echo "Camunda helm chart repo is being added"
        helm repo add camunda https://helm.camunda.io
    fi

    echo "Camunda cluster is being deployed"
    helm install -f ./config/camunda-value.yaml \
        process-$DEP_CLUSTER_NAME camunda/camunda-platform || true
}
# setup_camunda_workers


##### Delegation takes place
if [ "$DO_DEPLOY" = true ]; then
    delete "$CONSUMER_SERVICE"
    delete "$PRODUCER_SERVICE"

    build "$CONSUMER_SERVICE"
    build "$PRODUCER_SERVICE"

    deploy "$CONSUMER_SERVICE" "$DEP_CLUSTER_NAME-cp-kafka:9092" \
        "http://$DEP_CLUSTER_NAME-cp-schema-registry:8081" "$OUTGOING_TOPIC"
    deploy "$PRODUCER_SERVICE" "$DEP_CLUSTER_NAME-cp-kafka:9092" \
        "http://$DEP_CLUSTER_NAME-cp-schema-registry:8081" "$INCOMING_TOPIC"
else
    helm repo update
    setup_kafka_cluster
    setup_camunda_cluster

    CONSUMER_EXISTENCE="$(kubectl get deployment --no-headers -o custom-columns=":metadata.name" | grep "$CONSUMER_SERVICE")"
    if [ -z "${CONSUMER_EXISTENCE}" ]; then
        wait_for_Kafka
        sleep 10
        create_topic "$INCOMING_TOPIC"
        sleep 2
        create_topic "$OUTGOING_TOPIC_1"
        sleep 2
        create_topic "$OUTGOING_TOPIC_2"
    fi
    
    config_connect
fi

echo "finished"