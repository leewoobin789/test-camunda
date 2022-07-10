CLUSTER_NAME = camunda-sandbox
CLUSTER_FULL_NAME = kind-${CLUSTER_NAME}
NAMESPACE = demo

PRODUCER-POD-NAME= $(shell kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep "producer-service")

.PHONY: dep-setup kind-delete kind-setup cluster-setup producer-console producer-app

dep-setup: 
	bash setup_dep.sh ${CLUSTER_NAME} ${NAMESPACE} false

deploy-service:
	bash setup_dep.sh ${CLUSTER_NAME} ${NAMESPACE} true

kind-delete:
	kind delete cluster --name ${CLUSTER_NAME}

kind-setup:
	kind create cluster --config=./kind-config.yml
	kubectl config use-context ${CLUSTER_FULL_NAME}
	kubectl create namespace ${NAMESPACE}
	kubectl config set-context --current --namespace=$(NAMESPACE)
	kubectl create secret docker-registry regcred --docker-username=RANDOM --docker-password=RANDOM --docker-email=RANDOM
	kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

cluster-setup: kind-delete kind-setup dep-setup deploy-service

produce-via-app:
	kubectl exec ${PRODUCER-POD-NAME} -- curl localhost:8080/send?number=${NUM}