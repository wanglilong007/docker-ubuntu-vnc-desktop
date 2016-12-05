from flask import (Flask,
                   request,
                   abort,
                   )
import os
import subprocess as sp
import time

# Flask app
app = Flask(__name__,
            static_folder='static', static_url_path='',
            instance_relative_config=True)
app.config.from_object(os.environ.get('CONFIG'))
app.config.from_pyfile('application.cfg')

# logging
import logging
from log.config import LoggingConfiguration
LoggingConfiguration.set(logging.INFO, 'lightop.log', name='web')

FIRST = True


HTML_INDEX = '''<html><head>
    <script type="text/javascript">
        var w = window,
        d = document,
        e = d.documentElement,
        g = d.getElementsByTagName('body')[0],
        x = w.innerWidth || e.clientWidth || g.clientWidth,
        y = w.innerHeight|| e.clientHeight|| g.clientHeight;
        window.location.href = "redirect.html?width=" + x + \
            "&height=" + (parseInt(y));
    </script>
    <title>Page Redirection</title>
</head><body></body></html>'''


HTML_REDIRECT = '''<html><head>
    <script type="text/javascript">
        var port = window.location.port;
        if (!port)
            port = window.location.protocol[4] == 's' ? 443 : 80;
        window.location.href = "vnc_auto.html?autoconnect=1" + \
            "&autoscale=0&quality=3";
    </script>
    <title>Page Redirection</title>
</head><body></body></html>'''


@app.route('/')
def index():
    return HTML_INDEX


@app.route('/redirect.html')
def redirectme():
    global FIRST

    if not FIRST:
        return HTML_REDIRECT

    env = {'width': 1024, 'height': 768}
    if 'width' in request.args:
        env['width'] = request.args['width']
    if 'height' in request.args:
        env['height'] = request.args['height']

    # sed
    sp.check_call([
        'sed', '-i',
        's#^RESOLUTION=.*#RESOLUTION={width}x{height}x16#'.format(**env),
        '/usr/local/bin/myxvfb'
    ])
    sp.check_call(['supervisorctl', 'restart', 'xvfb', 'x11vnc'])

    # check all running
    for i in xrange(20):
        for line in sp.check_output(['supervisorctl', 'status']).split('\n'):
            if len(line.strip()) <= 0:
                continue
            if line.find('RUNNING') < 0:
                break
        else:
            FIRST = False
            return HTML_REDIRECT
        time.sleep(2)
    abort(500, 'service is not ready, please restart container')


if __name__ == '__main__':
    app.run(host=app.config['ADDRESS'], port=app.config['PORT'])
