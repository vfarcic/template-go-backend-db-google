name: pr
run-name: pr
on:
  pull_request:
    types:
      - closed
jobs:
  build-container-image:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Apply the app
        run: |
          APP_ID=[[.AppName]]-${{ github.head_ref }}
          kubectl delete namespace $APP_ID
