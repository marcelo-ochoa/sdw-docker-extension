package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"

	"github.com/labstack/echo"
	"github.com/sirupsen/logrus"
)

var ttyd TTYD
var globaltheme Theme

func main() {
	var socketPath string

	flag.StringVar(&socketPath, "socket", "/run/guest-services/sdw-docker-extension.sock", "Unix domain socket to listen on")
	flag.Parse()

	os.RemoveAll(socketPath)

	logrus.New().Infof("Starting listening on %s", socketPath)
	router := echo.New()
	router.HideBanner = true

	startURL := ""

	ln, err := listen(socketPath)
	if err != nil {
		log.Fatal(err)
	}
	router.Listener = ln

	ttyd = TTYD{}

	router.GET("/ready", ready)
	router.POST("/start", start)

	log.Fatal(router.Start(startURL))
}

func listen(path string) (net.Listener, error) {
	return net.Listen("unix", path)
}

// ready checks whether sdw is ready or not by querying localhost:9080.
func ready(ctx echo.Context) error {
	if ttyd.IsRunning() {
		return ctx.String(http.StatusOK, "true")
	}

	return ctx.String(http.StatusServiceUnavailable, "false")
}

// start starts ttyd with the provided theme.
func start(ctx echo.Context) error {
	var newTheme Theme
	if err := ctx.Bind(&newTheme); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}
	if err := ttyd.Start(newTheme); err != nil {
		log.Printf("failed to start ttyd error is: %s\n", err)

		return echo.NewHTTPError(http.StatusInternalServerError)
	}

	return ctx.String(http.StatusOK, "true")
}

type HTTPMessageBody struct {
	Message string `json:"message"`
	Body    string `json:"body,omitempty"`
}

type Theme struct {
	Background string `json:"background" form="background" query="background"`
	Foreground string `json:"foreground" form="foreground" query="foreground"`
	Cursor     string `json:"cursor" form="cursor" query="cursor"`
	Selection  string `json:"selection" form="selection" query="selection"`
}

func (t Theme) String() string {
	b, err := json.Marshal(t)
	if err != nil {
		return ""
	}

	return string(b)
}

type TTYD struct {
	process *os.Process
}

func (t *TTYD) Start(theme Theme) error {
	if globaltheme.Background != theme.Background {
		if err := t.Stop(); err != nil {
			log.Printf("failed to stop ttyd: %s\n", err)
		}
		globaltheme = theme
	}
	if !t.IsStarted() {
		args := []string{"-c"}
		args = append(args, fmt.Sprintf("/home/sdw/sdw.sh -t 'theme=%s'", theme))
	
		cmd := exec.Command("/bin/bash", args...)
		if err := cmd.Start(); err != nil {
			return err
		}
	
		t.process = cmd.Process
		log.Println("started sdw.sh with theme:", globaltheme)
	}

	return nil
}

func (t *TTYD) Stop() error {
	if !t.IsStarted() {
		return nil
	}

	if err := t.process.Kill(); err != nil {
		log.Printf("failed to stop sdw.sh: %s\n", err)
		return err
	}
	t.process.Wait()
    t.process = nil

	return nil
}

func (t TTYD) IsStarted() bool {
	return t.process != nil
}

func (t *TTYD) IsRunning() bool {
	if !t.IsStarted() {
		return false
	}

	url := "http://localhost:8080/ords/sql-developer" // Jetty listening on 8080
	resp, err := http.Get(url)
	if err != nil {
		log.Println(err)
		return false

	}

	return resp.StatusCode == http.StatusOK
}
