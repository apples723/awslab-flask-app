# syntax=docker/dockerfile:1
FROM python:buster

WORKDIR /app
 ADD ./requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
ADD . /app
EXPOSE 443/tcp
CMD python3 app.py