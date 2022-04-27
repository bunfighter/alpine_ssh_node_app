# build: docker build -t bunfight-alpine-sshd --build-arg my_password="EnPidäSpamista" .
#   run: docker run -it --rm -p 2222:22 -p 8080:8080 bunfight-alpine-sshd

# - adds sshd to alpine with a public key of your choice.
# - publishes the sshd on 22
# - runs a demo node app on localhost:8080
# to avoid conflicts I recommend routing the ssh port 22 to port 2222 in the docker start (see "run:" above)

# Just a demo - better to pick the node version you need such as "FROM node:14.19.1-alpine"
FROM node:alpine

# network for sshd
EXPOSE 22

# network for demo node app
EXPOSE 8080

# get the password for the soon to be created user "me".
#   It is passed in on the docker build command line with:
#     --build-arg my_password="this_is_my_super_secret_password"
ARG my_password

# install and configure sshd and sudo
RUN apk add --update --no-cache openssh sudo \
    && echo '%wheel ALL=(ALL) ALL' > /etc/sudoers.d/wheel \
    && echo -e "LogLevel INFO" >> /etc/ssh/sshd_config \
    && echo -e "PubkeyAuthentication yes" >> /etc/ssh/sshd_config \
    && echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Set up the "me" user account to ssh in with
RUN adduser -h /home/me -s /bin/sh -D me \
    && mkdir -p /home/me/.ssh \
    && chown me:me /home/me/.ssh \
    && chmod 0700 /home/me/.ssh \
    && echo -n "me:$my_password" | chpasswd \
    && adduser me wheel

# copy in the entrypoint script
COPY entrypoint.sh /

# copy in the demo node app
COPY nodetest.js /

# copy in my public key and set it as the only authorised key
COPY authorized_keys /home/me/.ssh/authorized_keys

# set the correct permissions for the public key file
RUN chown me:me /home/me/.ssh/authorized_keys \
    && chmod 644 /home/me/.ssh/authorized_keys

# set up the entrypoint and cmd
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "/nodetest.js"]
