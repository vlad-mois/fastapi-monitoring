#!/bin/bash

./node_exporter &
uvicorn main:app --app-dir app --host 0.0.0.0 --port 8080 --reload --log-config app/log.ini &
tail -f /var/log/some-server.log
