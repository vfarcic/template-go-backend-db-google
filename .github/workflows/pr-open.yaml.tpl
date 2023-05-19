name: pr-open
run-name: pr-open
on:
  pull_request:
    types:
      - opened
      - edited
      - reopened
jobs:
  deploy:
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
          echo "APP_ID=$APP_ID" >> "$GITHUB_ENV"
          HOST=$(yq ".spec.parameters.host" kustomize/overlays/previews/app-patch.yaml)
          echo "HOST=$HOST" >> "$GITHUB_ENV"
          yq --inplace ".spec.id = \"$APP_ID\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.namespace = \"$APP_ID\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.image = \"${{ secrets.DOCKERHUB_USER }}/[[.AppName]]:0.0.${{ github.run_number }}\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.parameters.host = \"pr-${{ github.event.number }}-$HOST\"" kustomize/overlays/previews/app-patch.yaml
          yq --inplace ".spec.connection.postgres.host.value = \"$APP_ID-postgresql\"" kustomize/overlays/previews/schema-patch.yaml
          yq --inplace ".spec.connection.postgres.password.valueFrom.secretKeyRef.name = \"$APP_ID-postgresql\"" kustomize/overlays/previews/schema-patch.yaml
          yq --inplace ".metadata.name = \"$APP_ID\"" kustomize/overlays/previews/namespace.yaml
          echo "${{ secrets.KUBECONFIG_PREVIEWS }}" >kubeconfig.yaml
          export KUBECONFIG=$PWD/kubeconfig.yaml
          kubectl --namespace $APP_ID apply --kustomize kustomize/overlays/previews
      - uses: thollander/actions-comment-pull-request@v2
        with:
          message: |
            The application was deployed to a preview environment in the namespace **${{ env.APP_ID }}**.
            It is currently based on the image **${{ secrets.DOCKERHUB_USER }}/test:1.2.${{ github.run_number }}**.
            It is accessible through http://pr-${{ github.event.number }}-${{ env.HOST }}.
            Once the pull request is merged, the whole preview environment will be **removed** :skull:
          comment_tag: execution
