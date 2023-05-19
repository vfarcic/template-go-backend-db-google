apiVersion: databases.schemahero.io/v1alpha4
kind: Database
metadata:
  name: [[.AppName]]
spec:
  connection:
    postgres:
      host:
        value: [[.AppName]]-postgresql
      password: 
        valueFrom:
          secretKeyRef:
            name: [[.AppName]]-postgresql
