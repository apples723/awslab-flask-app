from flask import Flask, redirect, request, url_for
import os
import json
import random 
app = Flask(__name__)

#GLOBAL APP RESPONSES
global_health = True
if global_health:
    global_status = 200
if global_health == False:
    global_status = 400

#changable health response
@app.route("/health/global")
def health_check():
    return f"Is the cloud healthy? Status: {global_health}", global_status

@app.route("/health/update",)


#random health status for r53 checking
@app.route("/health")
def random_health_check():
    status_code_choices = ["200", "201", "400", "401", "402", "403", "404", "302"]
    status_code = random.choice(status_code_choices)
    if status_code == "302":
        return url_for(redirected)
    return f"Status code {status_code}", int(status_code)

@app.route("/ping")
def ping():
  return "pong", 200

@app.route("/health/good")
def healthy():
    return "What a healthy cloud!", 200

@app.route("/health/bad")
def unhealthy():
    return "I am not a healthy cloud!", 400

#Redirect (302)
@app.route("/health/redirect")
def health_redirect():
    return redirect("/redirected")

@app.route("/redirected")
def redirected():
    return  "The cloud redirected you here!", 302

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)