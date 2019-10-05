FROM python:3.7-slim

RUN apt-get update \
    && apt-get install -y procps \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

ADD requirements.pip /requirements.pip

RUN pip install pip --upgrade \
    && pip install -r /requirements.pip

ADD ./app /app

WORKDIR /app

USER nobody
