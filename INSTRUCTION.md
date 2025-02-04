

# to taint mysql nodes 
1. get mysql nodes by command `kubectl get nodes --show-labels`
2. execute command `kubectl taint nodes {node_mysql#1} {node_mysql#2} app=mysql:NoSchedule`

## deploy application:
To deploy application run `./bootstrap.sh`

# to check if application works:
Open next URL in browser: `http://localhost/`