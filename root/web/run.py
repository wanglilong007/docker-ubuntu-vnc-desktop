#!/usr/bin/env python
import os
import sys
import signal
import socket


def killpg(pgid, send_signal=signal.SIGKILL):
    print('kill PGID {}'.format(pgid))
    try:
        os.killpg(pgid, send_signal)
        #os.killpg(pgid, signal.SIGKILL)
    except:
        pass


def create_instance_config():
    if not os.path.exists('instance'):
        os.makedirs('instance')

    with open(os.path.join('instance', 'application.cfg'), 'wb+') as f:
        f.write('SECRET_KEY = \'')
        f.write("".join("\\x{:02x}".format(ord(c)) for c in os.urandom(24)))
        f.write('\'\n')
        f.write('VERSION = \'')
        if os.path.exists('version'):
            with open('version') as fv:
                version = fv.read().strip()
            f.write(version)
        else:
            f.write('unknown')
        f.write('\'\n')
    if '--debug' not in sys.argv:
        os.chmod(os.path.join('instance', 'application.cfg'), 0600)


def main():
    create_instance_config()

    from lightop import app
    PORT = 6079
    os.environ['CONFIG'] = 'config.Production'

    pgid = os.getpgid(0)
    signal.signal(signal.SIGCHLD, signal.SIG_IGN)
    signal.signal(signal.SIGTERM, lambda *args: killpg(pgid))
    signal.signal(signal.SIGHUP, lambda *args: killpg(pgid))
    signal.signal(signal.SIGINT, lambda *args: killpg(pgid))

    print('Running on port ' + str(PORT))
    try:
        app.run(host='', port=PORT)
    except socket.error as e:
        print(e)


if __name__ == "__main__":
    main()
