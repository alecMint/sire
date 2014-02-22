
#Happiness / marketing

## ports

these ports must be open in the security group for this deployment to funciton correctly.
deployment port tests should warn you that

```sh
tcp 80            # web
tcp 7777          # static assets (happiness). configurable.
tcp 0.0.0.0 9998  # hook server
```



