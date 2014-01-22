# ensure the apt supervisor package is gone
apt-supervisor:
    pkg.purged

# kill off apt's old supervisor process
"pkill -f /usr/bin/supervisord":
    cmd.run:
        - onlyif: 'ps auxww | grep /usr/bin/supervisord | grep -v grep'

# install supervisor from pip because: not 5 years old
supervisor:
    pip.installed:
        - name: "supervisor==3.0"
    service:
        - name: supervisor
        - running
        - require:
            - file: /etc/default/supervisor
            - file: /etc/init.d/supervisor
            - file: /etc/supervisor/supervisord.conf
            - file: /var/log/supervisor
        - watch:
            - file: /etc/default/supervisor
            - file: /etc/init.d/supervisor
            - file: /etc/supervisor/supervisord.conf

/etc/init.d/supervisor:
    file.managed:
        - source: salt://supervisor/files/init
        - mode: 755
        - require:
            - pip: supervisor

/etc/default/supervisor:
    file.managed:
        - source: salt://supervisor/files/default
        - require:
            - pip: supervisor

/etc/supervisor/supervisord.conf:
    file.managed:
        - source: salt://supervisor/files/supervisord.conf
        - require:
            - pip: supervisor

/var/log/supervisor:
    file.directory

/usr/bin/supervisord:
    file.symlink:
        - target: /usr/local/bin/supervisord

/usr/bin/supervisorctl:
    file.symlink:
        - target: /usr/local/bin/supervisorctl

/usr/local/etc:
    file.directory

/usr/local/etc/supervisord.conf:
    file.symlink:
        - target: /etc/supervisor/supervisord.conf
        - require:
            - file: /usr/local/etc