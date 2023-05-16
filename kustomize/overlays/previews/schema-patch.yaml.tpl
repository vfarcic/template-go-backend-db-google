apiVersion: devopstoolkitseries.com/v1alpha1
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
