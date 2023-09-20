from flask import Flask, redirect, request
import os
import json
app = Flask(__name__)

#GLOBAL APP RESPONSES
global_health = True
if global_health:
    global_status = 200
if global_health == False:
    global_status = 400


#changable health response
@app.route("/health")
def health_check():
    return f"Is the cloud healthy? Status: {global_health}", global_status

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

 