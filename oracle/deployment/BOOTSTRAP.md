# Initializing FluxCD
Use the following commands to bootstrap FluxCD:

```bash
ssh-keygen -t ed25519 -C oracle -f ./oracle

flux bootstrap git \
    --url=ssh://git@github.com/parzival-space/clusters.git \
    --branch=development \
    --private-key-file=./oracle \
    --path=oracle/deployment/flux \
    --author-name=fluxcdbot \
    --author-email=fluxcdbot@users.noreply.github.com \
    --components-extra=image-reflector-controller,image-automation-controller
    
rm ./oracle ./oracle.pub
```
