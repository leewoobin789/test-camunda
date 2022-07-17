CLUSTER_NAME = camunda-sandbox
CLUSTER_FULL_NAME = kind-${CLUSTER_NAME}
NAMESPACE = demo

PRODUCER-POD-NAME= $(shell kubectl get pods --no-headers -o custom-columns=":metadata.name" | grep "producer-service")

dep-setup: 
	bash setup_dep.sh ${CLUSTER_NAME} ${NAMESPACE} false

deploy-service:
	bash setup_dep.sh ${CLUSTER_NAME} ${NAMESPACE} true

kind-delete:
	kind delete cluster --name ${CLUSTER_FULL_NAME}

kind-setup:
	kind create cluster --config=./config/kind-config.yaml
	kubectl config use-context ${CLUSTER_FULL_NAME}
	kubectl create namespace ${NAMESPACE}
	kubectl config set-context --current --namespace=$(NAMESPACE)
	kubectl create secret docker-registry regcred --docker-username=RANDOM --docker-password=RANDOM --docker-email=RANDOM
	kubectl apply -f ./config/metric-server.yaml

cluster-setup: kind-delete kind-setup dep-setup deploy-service

produce-via-app:
	kubectl exec ${PRODUCER-POD-NAME} -- curl localhost:8080/send?number=${NUM}

pf-cc:
	kubectl port-forward service/demo-cp-control-center 9021:9021

pf-sr:
	kubectl port-forward service/demo-cp-schema-registry 8081:8081

pf-co:
	kubectl port-forward service/process-demo-operate 8000:80

pf-czg:
	kubectl port-forward service/process-demo-zeebe-gateway 26500:26500