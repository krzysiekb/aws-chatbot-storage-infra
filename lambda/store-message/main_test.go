package main

import (
	"context"
	"testing"

	"github.com/aws/aws-lambda-go/events"
)

func TestHandleMessage(t *testing.T) {

	t.Run("valid event", func(t *testing.T) {
		event := events.SQSEvent{
			Records: []events.SQSMessage{
				{
					MessageId: "1",
					Body:      "Hello World",
				},
			},
		}

		err := HandleMessage(context.Background(), event)

		if err != nil {
			t.Errorf("Expected nil, got %v", err)
		}
	})

	t.Run("empty event", func(t *testing.T) {
		event := events.SQSEvent{
			Records: []events.SQSMessage{},
		}

		err := HandleMessage(context.Background(), event)

		if err != nil {
			t.Errorf("Expected nil, got %v", err)
		}
	})
}
