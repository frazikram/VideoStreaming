package config

import "os"

type Config struct {
	Env      string
	HTTPPort string
}

func Load() Config {
	return Config{
		Env:      getenv("APP_ENV", "dev"),
		HTTPPort: getenv("HTTP_PORT", "8080"),
	}
}

func getenv(k, def string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return def
}
