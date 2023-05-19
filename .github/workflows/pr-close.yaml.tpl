name: pr-close
run-name: pr-close
on:
  pull_request:
    types:
      - closed
jobs:
  destroy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Remove the app
        run: |
          APP_ID=[[.AppName]]-${{ github.head_ref }}
          echo "${{ secrets.KUBECONFIG_PREVIEWS }}" >kubeconfig.yaml
          export KUBECONFIG=$PWD/kubeconfig.yaml
          kubectl delete namespace $APP_ID
