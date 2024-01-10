package config

import (
	"os"
)

type runMode string

const (
	rubModeDev  runMode = "dev"
	runModeProd runMode = "prd"
)

type Config struct {
	runMode     runMode
	host        string
	port        string
	pubClientID string
	pubUsername string
	pubPassword string
	subClientID string
	subUsername string
	subPassword string
}

func NewConfig() *Config {
	return &Config{
		runMode:     runMode(os.Getenv("RUN_MODE")),
		host:        os.Getenv("AWS_IOT_MQTT_HOST"),
		port:        os.Getenv("AWS_IOT_MQTT_PORT"),
		pubClientID: os.Getenv("AWS_IOT_MQTT_PUB_CLIENT_ID"),
		pubUsername: os.Getenv("AWS_IOT_MQTT_PUB_USERNAME"),
		pubPassword: os.Getenv("AWS_IOT_MQTT_PUB_PASSWORD"),
		subClientID: os.Getenv("AWS_IOT_MQTT_SUB_CLIENT_ID"),
		subUsername: os.Getenv("AWS_IOT_MQTT_SUB_USERNAME"),
		subPassword: os.Getenv("AWS_IOT_MQTT_SUB_PASSWORD"),
	}
}

func (c *Config) IsDev() bool {
	return c.runMode == rubModeDev
}

func (c *Config) Host() string {
	return c.host
}

func (c *Config) Port() string {
	return c.port
}

func (c *Config) PubClientID() string {
	return c.pubClientID
}

func (c *Config) PubUsername() string {
	return c.pubUsername
}

func (c *Config) PubPassword() string {
	return c.pubPassword
}

func (c *Config) SubClientID() string {
	return c.subClientID
}

func (c *Config) SubUsername() string {
	return c.subUsername
}

func (c *Config) SubPassword() string {
	return c.subPassword
}
