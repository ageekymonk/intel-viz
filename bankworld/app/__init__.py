from flask import Flask
from flask.ext.bootstrap import Bootstrap
from config import config
from flask_cake import Cake
import psycopg2

bwinfo = 0
conn = psycopg2.connect("dbname=ramz user=ramz")
cur = conn.cursor()
def create_app(config_name):
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    cake = Cake(app)

    bootstrap = Bootstrap()
    bootstrap.init_app(app)

    from .bankworld import app as app_blueprint
    app.register_blueprint(app_blueprint)

    return app