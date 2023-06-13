import flask
from flask import Flask
import sqlite3
from sqlite3 import OperationalError
import os
import subprocess

import sys

argv = sys.argv

basedir = os.path.abspath(os.path.dirname(__file__))

app = Flask("Parking")

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'parking.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


def startup():
    init_db_script = open('init_db.sql')
    created_tables = init_db_script.read().split(";")
    db = sqlite3.connect('parking.db', timeout=25)
    for table in created_tables:
        print(table)
        # drop tables
        # db.execute(table)
    db.close()

@app.route("/gas-alerts", methods=['GET'])
def gas_alerts():
    logs = []

    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM GAS_ALERTS ORDER BY TIMESTAMP DESC")
        for row in cursor:
            log = {'timestamp' : row[0]}
            logs.append(log)

        db.close()
        response = flask.jsonify(logs)
        return response
    except OperationalError:
        return {'success' : False}
    
@app.route("/gas-alerts/last", methods=['GET'])
def last_gas_alert():
    log = {}

    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM GAS_ALERTS ORDER BY TIMESTAMP DESC LIMIT 1")
        for row in cursor:
            log = {'timestamp' : row[0]}
            

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}
    

@app.route("/entries", methods=['GET'])
def entries():
    entries = []
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM entries ORDER BY entry_timestamp DESC")
        for row in cursor:
            log = {'license_plate_number' : row[1], 'entry_timestamp': row[2], 'exit_timestamp': row[3], 'paid': row[4], 'fee': row[5]}
            entries.append(log)

        db.close()
        response = flask.jsonify(entries)
        return response
    except OperationalError:
        return {'success' : False}
    

@app.route("/entries/total", methods=['GET'])
def unique_entries():
    log = {}
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT COUNT(*) FROM entries")
        for row in cursor:
            log = {'total_entries' : row[0]}

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}
    
@app.route("/entries/unique", methods=['GET'])
def total_entries():
    log = {}
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT COUNT(DISTINCT license_plate_number) FROM entries")
        for row in cursor:
            log = {'unique_entries' : row[0]}

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}
    

@app.route("/entries/current/count", methods=['GET'])
def occupied():
    log = {}
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT COUNT(*) FROM entries WHERE exit_timestamp = 0")
        for row in cursor:
            log = {'occupied' : row[0]}

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}
    
@app.route("/entries/current", methods=['GET'])
def current_vehicles():
    vehicles = []
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM entries WHERE exit_timestamp = 0")
        for row in cursor:
            log = {'license_plate_number' : row[1], 'entry_timestamp': row[2], 'exit_timestamp': row[3], 'paid': row[4], 'fee': row[5]}
            vehicles.append(log)

        db.close()
        response = flask.jsonify(vehicles)
        return response
    except OperationalError:
        return {'success' : False}
    
@app.route("/entries/fees/sum", methods=['GET'])
def fees_sum():
    log = {}
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT sum(fee) FROM entries")
        for row in cursor:
            log = {'fees_sum' : row[0]}

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}

@app.route("/entries/fees/avg", methods=['GET'])
def fees_avg():
    log = {}
    db = sqlite3.connect('parking.db', timeout=20)
    cursor = db.cursor()
    try:
        cursor.execute("SELECT avg(fee) FROM entries WHERE exit_timestamp <> 0")
        for row in cursor:
            log = {'fees_avg' : row[0]}

        db.close()
        response = flask.jsonify(log)
        return response
    except OperationalError:
        return {'success' : False}



if __name__ == "__main__":
    startup()
    subprocess.Popen(["sudo", "python", "gascheck.py"])
    if argv[1] == "EXIT":
        subprocess.Popen(["python", "camera.py", "EXIT"])
    elif argv[1] == "ENTRY":
        subprocess.Popen(["python", "camera.py", "ENTRY"])
    elif argv[1] == "QRCODE":
        subprocess.Popen(["python", "qrcode.py"])
    
    app.run(host='0.0.0.0', ssl_context=('cert.pem', 'key.pem'))