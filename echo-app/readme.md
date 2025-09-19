# Echo App

The echo app is a lightweight HTTP server ([ealen/echo-server](https://hub.docker.com/r/ealen/echo-server)) that returns
a JSON document describing the request it received.

## How the Ingress Setup Works

1. **Ingress-NGINX Controller**  
   - Runs in the `ingress-nginx` namespace.  
   - Exposed as a `LoadBalancer` service (via `minikube tunnel`).  
   - Listens on ports 80/443.

2. **Ingress Resource**  
   - Routes the host `echo.$IP.nip.io` to the `echo` Service on port 80.  
   - NGINX reads this and acts as a reverse proxy.

3. **Service/echo (ClusterIP)**  
   - Internal-only service fronting the echo pods.  
   - The controller forwards requests here.

4. **Deployment/echo**  
   - Runs the `ealen/echo-server` container.  
   - Each pod echoes back request metadata.

## How to Use

### 0 Ensure ingress is enabled and ready (you already have targets)
```
make addons
make wait
```

### 1 Get IP
```
IP=$(make -s ip)
echo "Minikube IP: $IP"
```

### 2 Apply namespace
```
kubectl apply -f namespace.yaml
```

### 3 Apply app + service
```
kubectl -n echo apply -f deployment.yaml -f service.yaml
```

### 4 Render the Ingress host and apply
```
sed "s/REPLACE_ME_NODES_IP/$IP/" ingress.yaml | kubectl -n echo apply -f -
```

### 5 Watch readiness
```
kubectl -n echo rollout status deploy/echo
```

### 6 Expose the NGINX controller as a LoadBalancer (one-time only)
```
kubectl -n ingress-nginx patch svc ingress-nginx-controller \
  -p '{"spec":{"type":"LoadBalancer"}}'
```

### 7 Start the tunnel (required for :80/:443; keep this terminal open)
```
sudo -E minikube tunnel --profile cute-kube-lab
```

### 8  Test the Ingress on port 80
```
LB_IP=$(kubectl -n ingress-nginx get svc ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "Controller LB IP: ${LB_IP}"
echo "Ingress Host: echo.${IP}.nip.io"

curl -i -H "Host: echo.${IP}.nip.io" "http://${LB_IP}/"
```