# hello_gunicorn

**hello_gunicorn** illustrates running a simple Python Flask app with Gunicorn
as the WSGI.

### Background

For a Python web application run in production, a [WSGI](https://wsgi.readthedocs.io/en/latest/) should be used.
[Gunicorn](https://gunicorn.org/) and [UWSGI](https://uwsgi-docs.readthedocs.io/en/latest/) are common choices.

For local development, it is common to use Flask's built-in development server
to run the application. Thus the container's start command could be:
```bash
$ FLASK_APP=app.py FLASK_ENV=development flask run
 * Serving Flask app "app.py" (lazy loading)
 * Environment: development
 * Debug mode: on
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 144-699-287
```

However, even in dev you can run the application with Gunicorn, just like you would
in production. That is what is done in this repo.

This repo is intended for local use. A sample YAML file for a Kubernetes Deployment
is included as an example, mainly to show the slight difference in Flask and Gunicorn
settings appropriate for production (i.e., not running Flask in debug mode, and
skipping two Gunicorn settings not relevant to a production environment). For a
Kubernetes cluster with an nginx ingress controller already included, it is not
necessary to run a separate nginx container in front of this Flask container.
(Contrast to a non-Kubernetes production environment, for which
[it is recommended](http://docs.gunicorn.org/en/latest/deploy.html#nginx-configuration)
to run nginx in front of Gunicorn.)

### Usage

On a machine with Docker installed (I use Docker for Mac for local development),
do `make build` to build the Docker image. Then run a container with `make up`,
which will log to stdout:
```bash
$ make up
+----------------------------+
| Starting a Flask container |
+----------------------------+
docker-compose up
Creating network "hello_gunicorn_default" with the default driver
Creating flask-app ... done
Attaching to flask-app
flask-app | [2019-08-03 19:00:00 +0000] [1] [INFO] Starting gunicorn 19.9.0
flask-app | [2019-08-03 19:00:00 +0000] [1] [INFO] Listening at: http://0.0.0.0:5000 (1)
flask-app | [2019-08-03 19:00:00 +0000] [1] [INFO] Using worker: sync
flask-app | [2019-08-03 19:00:00 +0000] [8] [INFO] Booting worker with pid: 8
flask-app | [2019-08-03 19:00:00 +0000] [9] [INFO] Booting worker with pid: 9
flask-app | [2019-08-03 19:00:00 +0000] [12] [INFO] Booting worker with pid: 12
flask-app | [2019-08-03 19:00:00 +0000] [14] [INFO] Booting worker with pid: 14
```

Curl the endpoint to reach the app:
```bash
$ curl -s localhost:5000 | jq
{
  "message": "Hello!"
}
```

The request and reponse are logged by gunicorn:
```bash
flask-app | 172.26.0.1 - - [03/Aug/2019:19:00:50 +0000] "GET / HTTP/1.1" 200 26 "-" "curl/7.63.0"
```

Open a bash shell on the container with `make shell` and list the processes:
```bash
$ make shell
----------------------------------
- Entering Flask container shell -
----------------------------------
docker-compose exec app bash
nobody@7bfa211ec630:/app$ ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
nobody       1     0  0 18:59 ?        00:00:00 /usr/local/bin/python /usr/local/bin/gunicorn -c conf/gunicorn.py app:app
nobody       8     1  0 19:00 ?        00:00:00 /usr/local/bin/python /usr/local/bin/gunicorn -c conf/gunicorn.py app:app
nobody       9     1  0 19:00 ?        00:00:00 /usr/local/bin/python /usr/local/bin/gunicorn -c conf/gunicorn.py app:app
nobody      12     1  0 19:00 ?        00:00:00 /usr/local/bin/python /usr/local/bin/gunicorn -c conf/gunicorn.py app:app
nobody      14     1  0 19:00 ?        00:00:00 /usr/local/bin/python /usr/local/bin/gunicorn -c conf/gunicorn.py app:app
nobody      25     0  1 19:02 pts/0    00:00:00 bash
nobody      30    25  0 19:02 pts/0    00:00:00 ps -ef
nobody@7bfa211ec630:/app$
```

Note the PIDs and the PPIDs (parent PIDs). PID 1 is the start command specified in the docker-compose
file. The docker-compose file also specifies that gunicorn should run 4 workers. Note that PIDs
8, 9, 12, and 14 have PPID = 1, meaning they are children of the main gunicorn process (PID 1).

To stop and remove the container, do `make down`.
