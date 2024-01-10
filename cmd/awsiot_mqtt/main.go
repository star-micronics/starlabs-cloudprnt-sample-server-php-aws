package main

import (
	"awsiot_mqtt/client"
	"awsiot_mqtt/config"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	if len(os.Args) < 2 {
		log.Print("pub or sub subcommand is required")
		os.Exit(1)
		return
	}

	cfg := config.NewConfig()

	switch os.Args[1] {
	case "pub":
		if err := execPublish(cfg); err != nil {
			log.Print(err)
			os.Exit(1)
			return
		}

		os.Exit(0)
		return
	case "sub":
		if err := runSubscriber(cfg); err != nil {
			log.Print(err)
			os.Exit(1)
			return
		}

		os.Exit(0)
		return
	default:
		log.Print("pub or sub subcommand is required")
		os.Exit(1)
		return
	}
}

func execPublish(cfg *config.Config) error {
	fs := flag.NewFlagSet("pub", flag.ExitOnError)
	topic := fs.String("t", "", "topic to publish to")
	payload := fs.String("m", "{}", "JSON format message to publish")

	if err := fs.Parse(os.Args[2:]); err != nil {
		return fmt.Errorf("%w", err)
	}

	if *topic == "" {
		err := errors.New("topic is empty")
		return fmt.Errorf("%w", err)
	}

	m := map[string]interface{}{}
	if err := json.Unmarshal([]byte(*payload), &m); err != nil {
		return fmt.Errorf("%w", err)
	}
	if len(m) == 0 {
		err := errors.New("payload is empty")
		return fmt.Errorf("%w", err)
	}

	cli, err := client.NewClient(cfg, false)
	if err != nil {
		return fmt.Errorf("%w", err)
	}

	err = cli.Publish(*topic, *payload)
	if err != nil {
		cli.Disconnect()
		return fmt.Errorf("%w", err)
	}

	cli.Disconnect()
	return nil
}

func runSubscriber(cfg *config.Config) error {
	fs := flag.NewFlagSet("sub", flag.ExitOnError)
	topic := fs.String("t", "", "topic")

	if err := fs.Parse(os.Args[2:]); err != nil {
		return fmt.Errorf("%w", err)
	}

	if *topic == "" {
		err := errors.New("topic is empty")
		return fmt.Errorf("%w", err)
	}

	// Create context that listens for the interrupt signal from the OS.
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	cli, err := client.NewClient(cfg, true)
	if err != nil {
		return fmt.Errorf("%w", err)
	}

	err = cli.Subscribe(*topic)
	if err != nil {
		cli.Disconnect()
		return fmt.Errorf("%w", err)
	}

	log.Print("subscribed")

	// Block until a signal is received.
	<-ctx.Done()

	err = cli.Unsubscribe(*topic)
	if err != nil {
		cli.Disconnect()
		return fmt.Errorf("%w", err)
	}

	cli.Disconnect()
	return nil
}
