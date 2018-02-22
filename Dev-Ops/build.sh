#!/bin/bash
check_fileexists(){
if [ -e   $1 ]
then
    return 1
else
    return 0
fi
}
check_fileexists examples
if [ $? = 0 ]
then
    git clone https://github.com/kubernetes/examples.git
else 
    echo git checked out exists
fi
kubectl create -f examples/guestbook-go/redis-master-controller.json
kubectl get rc
kubectl get pods
kubectl create -f examples/guestbook-go/redis-master-service.json
kubectl get services
kubectl create -f examples/guestbook-go/redis-slave-controller.json
kubectl get rc
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   apt-get install redis-server
   service redis-server restart
elif [[ "$unamestr" == 'Darwin' ]]; then
   brew install redis  # Install Redis using Homebrew
   ln -sfv /usr/local/opt/redis/*.plist ~/Library/LaunchAgents  # Enable Redis autostart
   launchctl load ~/Library/LaunchAgents/homebrew.mxcl.redis.plist  # Start Redis server via launchctl
   # homebrew.mxcl.redis.plist contains reference to redis.conf file location: /usr/local/etc/redis.conf 
   brew services start redis #start redis server
   #redis-server /usr/local/etc/redis.conf # Start Redis server using configuration file, Ctrl+C to stop
   redis-cli ping # Check if the Redis server is running
   launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.redis.plist # Disable Redis autostart
fi
#redis-server --slaveof redis-master 6379
kubectl get pods
kubectl create -f examples/guestbook-go/redis-slave-service.json
kubectl get services
kubectl create -f examples/guestbook-go/guestbook-controller.json
kubectl get rc
kubectl get pods
kubectl create -f examples/guestbook-go/guestbook-service.json
kubectl get services
python -mwebbrowser http://localhost:3000

