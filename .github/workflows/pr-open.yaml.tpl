name: pr
run-name: pr
on:
  pull_request:
    types:
      - opened
      - edited
      - reopened
jobs:
  build-container-image:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USER }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: [[.ImageRepo]]/[[.AppName]]:1.2.${{ github.run_number }}
      - name: Apply the app
        run: |
          APP_ID=[[.AppName]]-${{ github.event.number }}
          HOST=$(yq ".spec.parameters.host" kustomize/overlays/previews/app-patch.yaml)
          yq --inplace ".spec.id = \"$APP_ID\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.namespace = \"$APP_ID\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.image = \"${{ secrets.DOCKERHUB_USER }}/[[.AppName]]:1.2.${{ github.run_number }}\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.host = \"${{ github.head_ref }}-$HOST\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.connection.postgres.host.value = \"$APP_ID-postgresql\"" kustomize/overlays/previews/schema-patch.yaml
          yq --inplace ".spec.connection.postgres.password.valueFrom.secretKeyRef.name = \"$APP_ID-postgresql\"" kustomize/overlays/previews/schema-patch.yaml
          yq --inplace ".metadata.name = \"$APP_ID\"" kustomize/overlays/previews/namespace.yaml
          echo "${{ secrets.KUBECONFIG_PREVIEWS }}" >kubeconfig.yaml
          export KUBECONFIG=$PWD/kubeconfig.yaml
          kubectl --namespace $APP_ID apply --kustomize kustomize/overlays/previews
