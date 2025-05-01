# Instructions to Validate the Changes

1. **Verify Node Labels:**
    - Use `kubectl get nodes --show-labels` to verify that the nodes have the correct labels:
        - One node should have the label `app=todoapp`.
        - One node should have the label `app=mysql`.
2. **Verify Node Taints:**
   - Use `kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name}{'\t'}{range .spec.taints[*]}{.key}={.value}:{.effect}{'\t'}{end}{'\n'}"
   ` to view all taints that were created
3. **Verify MySQL StatefulSet Pod Scheduling:**
    - Use `kubectl get pods -n mysql -o wide` to see where the MySQL pod is scheduled.
    - Confirm that the MySQL pod is scheduled on the node with the `app=mysql` label
4. **Verify ToDo App Deployment Pod Scheduling:**
    - Use `kubectl get pods -n todoapp -o wide` to see where the ToDoApp pods are scheduled.
    - Confirm that the ToDo app pods are scheduled on the node with the `app=todoapp` label