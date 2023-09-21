from flask import Flask, redirect, request, url_for
import os
import json
import random 
import helpers as h
app = Flask(__name__)

global_status = int(open("status_code").read())
valid_status_codes = ["200", "201", "400", "401", "402", "403", "404", "302"]

@app.route("/whoami")
def whoami():
    instance_name = h.get_instance_name()
    return f"You currently are on instance: {instance_name}"

#changable health response
@app.route("/health/global")
def health_check():
    global_health = False
    global_status = int(open("status_code").read())
    print("health code:")
    print(global_status)
    if global_status >= 200 and global_status <= 299:
        global_health = True
    return f"Is the cloud healthy? Status: {global_health}", global_status

@app.route("/health/update/<status>")
def update_global_health(status):
    if len(status) != 3 or status not in valid_status_codes: 
        return f"You provided a invalid HTTP status code", 404
    with open("status_code", "w") as sf:
        sf.write(status)
        return f"Global status has been updated to {status}"

@app.route("/health")
def random_health_check():
    status_code_choices = ["200", "201", "400", "401", "402", "403", "404", "302"]
    status_code = random.choice(status_code_choices)
    if status_code == "302":
        return redirect(url_for("redirected"))
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