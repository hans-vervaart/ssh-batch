# ssh-batch

A set of 3 scripts to run commands as batch over multiple systems

Using the --bg-log-dir /path/to/log/directory option will let all sessions
run from the background.

Commands (little scripts) and hostnames can be provided from files.

ssh keys are not required, the password need to be entered once.
The included ssh_askpass script provides the password for each session.
