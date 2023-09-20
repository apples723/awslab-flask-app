# syntax=docker/dockerfile:1
FROM python:buster

WORKDIR /app

ADD ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
ADD . /app
EXPOSE 8000/tcp
CMD python3 main.py