package client

import (
	"awsiot_mqtt/config"
	"crypto/tls"
	"fmt"
	"log"
	"os"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type Client struct {
	paho mqtt.Client
}

func (c *Client) Disconnect() {
	c.paho.Disconnect(250)
}

func (c *Client) Publish(topic string, payload string) error {
	if token := c.paho.Publish(topic, 1, false, payload); token.Wait() && token.Error() != nil {
		return fmt.Errorf("%w", token.Error())
	}

	return nil
}

func (c *Client) Subscribe(topic string) error {
	if token := c.paho.Subscribe(topic, 1, func(client mqtt.Client, message mqtt.Message) {
		fmt.Fprintf(os.Stdout, "%s %s\n", message.Topic(), string(message.Payload()))
	}); token.Wait() && token.Error() != nil {
		return fmt.Errorf("%w", token.Error())
	}

	return nil
}

func (c *Client) Unsubscribe(topic string) error {
	if token := c.paho.Unsubscribe(topic); token.Wait() && token.Error() != nil {
		return fmt.Errorf("%w", token.Error())
	}

	return nil
}

func NewClient(cfg *config.Config, isSubscriber bool) (*Client, error) {
	mqtt.ERROR = log.New(os.Stdout, "[ERROR] ", 0)
	if cfg.IsDev() {
		mqtt.CRITICAL = log.New(os.Stdout, "[CRIT] ", 0)
		mqtt.WARN = log.New(os.Stdout, "[WARN] ", 0)
		mqtt.DEBUG = log.New(os.Stdout, "[DEBUG] ", 0)
	}

	var (
		ci = cfg.PubClientID()
		un = cfg.PubUsername()
		pw = cfg.PubPassword()
	)

	if isSubscriber {
		ci = cfg.SubClientID()
		un = cfg.SubUsername()
		pw = cfg.SubPassword()
	}

	tlsConfig := &tls.Config{
		NextProtos: []string{"mqtt"},
	}

	opts := mqtt.NewClientOptions().
		AddBroker(fmt.Sprintf("mqtts://%s:%s", cfg.Host(), cfg.Port())).
		SetClientID(ci).
		SetUsername(un).
		SetPassword(pw).
		SetTLSConfig(tlsConfig).
		SetProtocolVersion(4)

	paho := mqtt.NewClient(opts)
	if token := paho.Connect(); token.Wait() && token.Error() != nil {
		return nil, fmt.Errorf("%w", token.Error())
	}

	return &Client{paho}, nil
}
