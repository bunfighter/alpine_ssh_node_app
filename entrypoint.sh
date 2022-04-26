#!/bin/sh

# this script is set in the ENTRYPOINT of the Dockerfile

# Generate all the ssh keys
ssh-keygen -A

# Start the sshd for the win
/usr/sbin/sshd -D -e &

# Finally start the node app (this runs whatever is set in Dockerfile CMD) - shiggles!
exec "$@"
