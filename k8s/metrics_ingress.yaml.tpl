apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fintech-metrics-ingress
  namespace: default
  annotations:
    # Apply the whitelist annotation only to this Ingress resource
    nginx.ingress.kubernetes.io/whitelist-source-range: "<Prometheus-Server-IP>/32"  # Prometheus-Server-IP dynamically populated by the wrapper k8s script
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /metrics
            pathType: Exact
            backend:
              service:
                name: fintech-service
                port:
                  number: 5000
