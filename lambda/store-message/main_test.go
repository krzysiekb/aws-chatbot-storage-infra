package main

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func TestHandleMessage(t *testing.T) {

	ctx := context.Background()

	req := testcontainers.ContainerRequest{
		Image:        "amazon/dynamodb-local:latest",
		Cmd:          []string{"-jar", "DynamoDBLocal.jar", "-inMemory"},
		ExposedPorts: []string{"8000/tcp"},
		WaitingFor:   wait.NewHostPortStrategy("8000"),
	}

	ddb, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		panic(err)
	}

	defer func() {
		if err := ddb.Terminate(ctx); err != nil {
			panic(err)
		}
	}()

	ip, err := ddb.Host(ctx)
	if err != nil {
		panic(err)
	}

	port, err := ddb.MappedPort(ctx, "8000")
	if err != nil {
		panic(err)
	}

	// create DynamoDB client
	ddbOptions := session.Options{
		Config: aws.Config{
			Endpoint:    aws.String(fmt.Sprintf("http://%s:%s", ip, port)),
			Region:      aws.String("eu-central-1"),
			Credentials: credentials.NewStaticCredentials("dummy", "dummy", ""),
		},
	}
	ddbClient := dynamodb.New(session.Must(session.NewSessionWithOptions(ddbOptions)))

	// create DynamoDB table
	_, err = ddbClient.CreateTable(&dynamodb.CreateTableInput{
		TableName: aws.String("Messages"),
		AttributeDefinitions: []*dynamodb.AttributeDefinition{
			{
				AttributeName: aws.String("chatId"),
				AttributeType: aws.String("S"),
			},
			{
				AttributeName: aws.String("messageId"),
				AttributeType: aws.String("S"),
			},
		},
		KeySchema: []*dynamodb.KeySchemaElement{
			{
				AttributeName: aws.String("chatId"),
				KeyType:       aws.String("HASH"),
			},
			{
				AttributeName: aws.String("messageId"),
				KeyType:       aws.String("RANGE"),
			},
		},
		ProvisionedThroughput: &dynamodb.ProvisionedThroughput{
			ReadCapacityUnits:  aws.Int64(5),
			WriteCapacityUnits: aws.Int64(5),
		},
	})
	if err != nil {
		panic(err)
	}

	// create Store Message handler
	s := StoreMessageHandler{}
	s.InitHandlerWithOptions(ddbOptions)

	// test valid message
	t.Run("valid event", func(t *testing.T) {
		recordBody, err := json.Marshal(&Message{ChatId: "1", MessageId: "1", MessageType: "text", Text: "test"})
		if err != nil {
			t.Errorf("Expected nil, got %v", err)
		}

		event := events.SQSEvent{
			Records: []events.SQSMessage{
				{
					MessageId: "1",
					Body:      string(recordBody),
				},
			},
		}

		err = s.HandleMessage(context.Background(), event)

		if err != nil {
			t.Errorf("Expected nil, got %v", err)
		}
	})
}
