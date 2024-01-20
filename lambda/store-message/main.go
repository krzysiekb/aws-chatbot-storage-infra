package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type Message struct {
	ChatId      string `json:"chatId"`
	MessageId   string `json:"messageId"`
	MessageType string `json:"messageType"`
	Text        string `json:"text"`
}

type StoreMessageHandler struct {
	ddb *dynamodb.DynamoDB
}

func (s *StoreMessageHandler) InitHandler() {
	options := session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}
	s.InitHandlerWithOptions(options)
}

func (s *StoreMessageHandler) InitHandlerWithOptions(options session.Options) {
	// create AWS session
	sess := session.Must(session.NewSessionWithOptions(options))
	// create DynamoDB client
	s.ddb = dynamodb.New(sess)
}

func (s *StoreMessageHandler) HandleMessage(ctx context.Context, sqsEvent events.SQSEvent) error {
	for _, record := range sqsEvent.Records {

		// unmarshal message body from json to Message
		var message Message
		err := json.Unmarshal([]byte(record.Body), &message)
		if err != nil {
			return fmt.Errorf("error unmarshalling message: %v", err)
		}

		// create AWS session
		sess := session.Must(session.NewSessionWithOptions(session.Options{
			SharedConfigState: session.SharedConfigEnable,
		}))

		// save message to DynamoDB
		err = s.saveMessage(sess, message)
		if err != nil {
			return fmt.Errorf("error saving message: %v", err)
		}
	}
	return nil
}

func (s *StoreMessageHandler) saveMessage(sess *session.Session, message Message) error {
	av, err := dynamodbattribute.MarshalMap(message)
	if err != nil {
		return err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String("Messages"),
	}

	_, err = s.ddb.PutItem(input)
	return err
}

func main() {
	s := StoreMessageHandler{}
	s.InitHandler()
	lambda.Start(s.HandleMessage)
}
