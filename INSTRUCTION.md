Run: bash bootstrap.sh
# 6 Worker nodes: 1-2 - mysql labels, 3-6 - todoapp labels
---
Run: kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
# Check taint in nodes our Cluster
---
Run: kubectl get nodes --show-labels
# Check labels in nodes our Cluster