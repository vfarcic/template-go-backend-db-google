---
apiVersion: databases.schemahero.io/v1alpha4
kind: Database
metadata:
  name: [[.AppName]]
spec:
  immediateDeploy: true
  connection:
    postgres:
      host:
        value: postgresql
      user:
        value: postgres
      password:
        valueFrom:
          secretKeyRef:
            name: postgresql
            key: postgres-password
      port:
        value: "5432"
      dbname:
        value: [[.AppName]]
---
apiVersion: schemas.schemahero.io/v1alpha4
kind: Table
metadata:
  name: [[.AppName]]-videos
spec:
  database: [[.AppName]]
  name: videos
  schema:
    postgres:
      primaryKey:
      - id
      columns:
      - name: id
        type: text
        constraints:
          notNull: true
      - name: title
        type: text
        constraints:
          notNull: true
