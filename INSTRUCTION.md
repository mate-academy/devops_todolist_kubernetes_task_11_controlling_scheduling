Run scripts
kind create cluster --config cluster.yml
./bootstrap.sh
After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
Run command kubectl get pods -n todoapp -o wide
Run command kubectl get pods -n mysql -o wide
You should see pods in different nodes
