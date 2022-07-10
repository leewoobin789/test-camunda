package endpoint

import (
	"os"

	"github.com/leewoobin789/test-camunda/producer-service/src/controller"
	"github.com/leewoobin789/test-camunda/producer-service/src/producer"
)

func ReturnBundle() []controller.Handler {
	server := os.Getenv("KAFKA_SERVER")
	customProducer := producer.NewCustomKafkaProducer(server)
	return []controller.Handler{
		newSendEndpoint(customProducer),
		newhealthEndpoint(),
	}
}
