---
apiVersion: devopstoolkitseries.com/v1alpha1
kind: AppClaim
metadata:
  annotations:
    gitHubOrg: [[.GitHubOrg]]
    gitHubRepo: [[.AppName]]
  name: [[.AppName]]
spec:
  id: [[.AppName]]
  compositionSelector:
    matchLabels:
      type: backend-db-google
      location: local
  parameters:
    namespace: development
    image: [[.ImageRepo]]/[[.AppName]]:latest
    port: 8080
    host: [[.Host]]
    db:
      version: "[[.DbVersion]]"
      size: [[.DbSize]]
