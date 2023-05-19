name: ci
run-name: ci
on:
  push:
    branches:
      - main
      - master
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
          tags: [[.ImageRepo]]/[[.AppName]]:latest,[[.ImageRepo]]/[[.AppName]]:0.0.${{ github.run_number }}
      - name: Update manifest
        run: yq --inplace '.spec.parameters.image = "[[.ImageRepo]]/[[.AppName]]:0.0.${{ github.run_number }}"' kustomize/overlays/production/app-patch.yaml
      - name: Commit changes
        run: |
          git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git config --local user.name "github-actions[bot]"
          git add .
          git commit -m "Release 0.0.${{ github.run_number }} [skip ci]"
      - name: Push changes
        uses: ad-m/github-push-action@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          branch: ${{ github.ref }}
