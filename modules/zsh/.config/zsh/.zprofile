#!/usr/bin/zsh

# Used to execute the user's commands at startup. Will be read when zsh starts as a login shell, which usually occurs once per login session.
# Typically used to start graphical sessions automatically and to set environment variables for the entire session.
# Should contain variables that initialize a session and that do not need to be reevaluated each time a new terminal window opens. Examples include variables exported by SSH or GPG agents, such as $SSH_AUTH_SOCK.
