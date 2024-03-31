# SSH-BATCH
<div align="right"><img align="right" src="extra/images/ssh-batch_icon.png" /></div>
A set of 3 scripts to run commands as batch over multiple systems.

- ssh-batch  (run commands remotely using `ssh` without temporal files on the systems)
- ssh_askpass (password vault using `openssl` for encryption)
- _option_processor (a powerful yet simple commandline parameter processor)

Commands (little scripts) and hostnames can be provided from files.

ssh keys are not required, the password need to be entered once.
The included ssh_askpass script provides the password for each session.

Author  : **Hans Vervaart**

To learn more about the basics, before diving into the man page, look at the presentation:
([ssh-batch.pdf](https://github.com/FBnil/ssh-batch/blob/master/extra/ssh-batch.pdf))

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

Using the `--bg-log-dir /path/to/log/directory` option will let all sessions run from the background.

### simple usage example

Run the content of the `script` on all servers in the file `hosts`
```sh
ssh-batch ./hosts -- ./script
```

Run a command on server1 and server2
```sh
ssh-batch server1 server2 - 'if [ $(hostname) == "server1" ];then echo "yes";else echo "no" ;fi'
```

----

## ssh_askpass

### Usage
```
ssh_askpass [options] [account] ..
```
Requires: _option_processor
Creates: A vault in `~/.ssh/`
#### Options

      --exports
      --flush-cache
      -h
      --help
      --no-set
      --no-trap
      --update-passwords
      --vault-create
      --vault-ignore
      --vault-relock
      --vault-remove

### Storing a single password in your vault

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
$ source ./ssh_askpass --exports --no-trap

 export SSH_ASKPASS_CACHE=H4sIAGug0l4AA1M2NDU2NeSySk23teUCAKiISCkNAAAA-
 export SSH_ASKPASS=/home/user/bin/ssh_askpass
 export DISPLAY=:0
 export SETSID=/usr/bin/setsid
```
Note: we __sourced__ `ssh_askpass`, we did not run it. But note that it also outputs the variables as text, so you can also run it and incorporate the output into the beginning of your dynamic scripts.

Tip: You can create different vaults, by symlinking to the binary. 
```sh
$ ln -s ssh_askpass banana_shake
$ ./banana_shake --vault-create
```
Would create `~/.banana/shake.vault`

Note: If you omit `--no-trap`, then Control-C will close your terminal.

### Storing multiple passwords in your vault
```sh
ssh_askpass --vault-create hv1234=AIX hv1234=Solaris hans@lin hans ""
```
This will request for 5 passwords + the vault secret (2x)
```
# [hv1234=AIX@ssh_askpass] Enter password:
# [hv1234=Solaris@ssh_askpass] Enter password:
# [hans@lin@ssh_askpass] Enter password:
# [hans@ssh_askpass] Enter password:
# [ssh_askpass] Enter password:
# [ssh_askpass] Lock vault secret:
# [ssh_askpass] Check vault secret:
```

A login with `hv1234@<system>` will be first searched in AIX, then in
Solaris, then with the direct regular expression `hv1234@lin.*` and
finaly the last unfiltered value will be returned.

A login with hans will return the 4th password and an unknown will return the last password.

Testing can be done by running:
```sh
#  ssh_askpass nobody@system
#  ssh_askpass hv1234@sun000001
#  ssh_askpass hv1234@aix100006
#  ssh_askpass hans@lin
#  ssh_askpass hans@pc
```

Note: as the binary, you can also use `$SSH_ASKPASS` or `${!___BIN}` as it is the full filename. To see all exported variables, use:
```sh
set |grep -i askpass
```

### Updating passwords in your vault

When managing the passwords in the vault:
```sh
ssh_askpass --update-passwords
```
Only the changed password need to be entered, the others can be skipped (old value) by pressing `<Enter>`

For equal named accounts with different passwords 2 facilities are available. The account can be provided including the `@<hostname-regular-expression>` or 
in the `~/.ssh/askpass` file (file was created during `--vault-create`). You can set up arrays with regular expressions. For example:

#### Example ~/.ssh/askpass
```sh
AIX=(
'aix000006'
'aix[1-9].*'
)
 
Solaris=(
'sun000001'
'sun[1-9].*'
)
```

 
 
 
### incorporating ssh_askpass into your scripts
You can also use ssh_askpass like so:
```sh
 #!/bin/bash
 
 # This line will request your to enter your password
 $(ssh_askpass --exports)
 
 COMMAND='ls -l'
 HOSTS="host1 host2 host3"
 
 for HOST in $HOSTS
 do
    $SETSID ssh $HOST "$COMMAND"
 done
```
For multiple user accounts, replace the line with the next line:
```sh
$(ssh_askpass --exports username1 username2 username3)
```
Running vaultless does have a disadvantage: You have to enter 3 passwords when running the script. By setting up the vault, only the vault secret will be requested.

----
## _option_processor
Source this in to get an automatic option processor, including long options.

### Usage example
```sh
$ ./example.sh -Q --foo-bar baz
yes
yes
baz
$ cat example.sh
. ./_option_processor
echo $_Q
echo $__foo_bar
if [ "$__foo_bar" = "yes" ];then
  echo $__foo_bar_ARG
fi
```


## long and short getopts

If a option has been used, then 
 Automatic `--option-processor` to var `__option_processor=yes`
  and      `-o`                 to var `_o=yes`
 
 For the long getopts (options starting with `--`), you can use
 only lowercase and numbers.
 For short getopts you can use lowercase, uppercase and numbers.
 
 ## Parameter arguments
 
 if `__option_processor_ARG` is defined as an empty string like:
 `__option_processor_ARG=""`
  and
 `_o_ARG=""`
 The passed argument will be put into the `__option_processor_ARG` or
 `_o_ARG` variable.

To see actual examples, peruse the code from `ssh-batch` and `ssh_askpass`.

## displaying help

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

----

## closevault  openvault  showvault
Helper scripts to quickly open/close/list a vault.

### Usage example
```sh
$ . ./openvault 
[ssh_askpass] Open vault secret:**********
```
note that you can use ". openvault" if it's in the path, but somehow that does not look easier to explain.

The added benefit is that you don't need to type out `source ssh_askpass --exports --no-trap`

Note: as you can symlink `ssh_askpass`, you can also symlink these commands:

```sh
$ ln -s ./openvault ./openvault-banana_shake
```

Note: Careful when closing a vault while having others open, as it unsets a few common variables (`DISPLAY`, `SETSID`), which might hinder ssh.
