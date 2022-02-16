from flask import Flask
from decouple import config
import os

#USER = os.getenv('ATC_USERNAME')
#PASSWORD = os.environ.get('ATC_PASSWORD')

USER = config('ATC_USERNAME')
PASSWORD = config('ATC_PASSWORD')

app = Flask(__name__)

@app.route('/')
def home():
    return '{} {}'.format(USER, PASSWORD)

app.run(host='0.0.0.0', port=81)

if __name__ == '__main__':
   app.run(debug = True)
