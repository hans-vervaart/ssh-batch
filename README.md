# SSH-BATCH

A set of 3 scripts to run commands as batch over multiple systems.

- ssh-batch
- ssh_askpass
- _option_processor

Commands (little scripts) and hostnames can be provided from files.

ssh keys are not required, the password need to be entered once.
The included ssh_askpass script provides the password for each session.
## ssh-batch

### Usage
```
   ssh-batch [options] hosts [[- adhoc-cmds]|[-- inline-files]][--- args]
```
#### Options

      --all-hosts
      --bg-disable
      --bg-log-dir                 <value>
      --bg-timout                  <value>
      --exit-status
      --no-info
      --no-ssh-askpass
      --ssh-option                 <value>
      --tags

Using the `--bg-log-dir /path/to/log/directory` option will let all sessions
run from the background.

## ssh_askpass

### Usage
```
ssh_askpass [options] [account] ..
```
#### Options

      --exports
      --flush-cache
      -h
      --help
      --no-set
      --update-passwords
      --vault-create
      --vault-ignore
      --vault-relock
      --vault-remove

### Example

The first thing we will want to do is create a vault to hold our password(s) in.
It will ask use first for the password we want stored, then it will add a lock on the vault by asking twice for the vault's password.
```sh
$ ./ssh_askpass --vault-create
[ssh_askpass] Enter password:****************
[ssh_askpass] Lock vault secret:****
[ssh_askpass] Check vault secret:****
[ssh_askpass] New vault content written
```
Note: You can update the password at any time with:
```sh
$ ./ssh_askpass --update-passwords
[ssh_askpass] Open vault secret:****
[ssh_askpass] Enter password:*******
[ssh_askpass] New vault content written
```

Then, when you need your password, you can have ssh-batch ask you for your vault password, or export the vault password into your environment (a bit obfuscated, for increased security), and ssh-batch will use that and not ask you for any password.
```sh
$ source ./ssh_askpass --exports

 export SSH_ASKPASS_CACHE=H4sIAGug0l4AA1M2NDU2NeSySk23teUCAKiISCkNAAAA-
 export SSH_ASKPASS=/bin/bash
 export DISPLAY=:0
 export SETSID=/usr/bin/setsid
```
Note: we __sourced__ `ssh_askpass`, we did not run it.But note that it also outputs the variables as text, so you can also run it and incorporate the output into the beginning of your dynamic scripts


## _option_processor
Source this in to get an automatic option processor, including long options.

### Usage
 

This variable is used in the help and the number of words before the
' [' or ' .' is counted to be the number of minimum arguments to be
passed as an argument.

#### 1 argument
 _help_show_args="arg1"
 _help_show_args="arg1 .."
 _help_show_args="arg1 [arg2]"
 _help_show_args="arg1 [arg2] .."

#### 2 arguments
 _help_show_args="arg1 arg2 [arg3] .."
 _help_show_args="arg1 arg2 .."


 Automatic `--option-processor` to var `__option_processor=yes`
  and      `_o`                 to var `_o=yes`
 Only lowercase and numbers starting with --
    and lowercase, uppercase and numbers staring with -
 if `__option_processor_ARG` is defined as an empty string like:
 `__option_processor_ARG=""`
  and
 `_o_ARG=""`
 The passed argument will be put into the `__option_processor_ARG` or
 `_o_ARG` variable.

To see actual examples, peruse the code from `ssh-batch` and `ssh_askpass`.