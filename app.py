#!/usr/bin/env python
"""
mascot: a microservice for serving mascot data from a MySQL database
"""
import json
import mysql.connector
from flask import Flask, jsonify, abort, make_response

APP = Flask(__name__)

# Database connection configuration
DB_CONFIG = {
    'user': 'your_user',
    'password': 'your_password',
    'host': 'mysql',
    'database': 'mascots_db',
}


def get_db_connection():
    """
    Function: get_db_connection
    Input: none
    Returns: A connection to the MySQL database
    """
    return mysql.connector.connect(**DB_CONFIG)


@APP.route('/', methods=['GET'])
def get_mascots():
    """
    Function: get_mascots
    Input: none
    Returns: A list of mascot objects from the MySQL database
    """
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM mascots")
    mascots = cursor.fetchall()
    conn.close()
    return jsonify(mascots)


@APP.route('/<guid>', methods=['GET'])
def get_mascot(guid):
    """
    Function: get_mascot
    Input: a mascot GUID
    Returns: The mascot object with GUID matching the input from the MySQL database
    """
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM mascots WHERE guid = %s", (guid,))
    mascot = cursor.fetchone()
    conn.close()
    if mascot:
        return jsonify(mascot)
    abort(404)


@APP.errorhandler(404)
def not_found(error):
    """
    Function: not_found
    Input: The error
    Returns: HTTP 404 with a JSON error message
    """
    return make_response(jsonify({'error': str(error)}), 404)


if __name__ == '__main__':
    APP.run("0.0.0.0", port=8081, debug=True)
