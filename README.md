# Finance Web

The way I'm doing forensics on my spending.

## Prerequisites

1. Ruby 3.4.5+

## Running

After building the container, you need to pass in the environment variable of `SECRET_KEY_BASE`

## Data

### Format

All data imported MUST follow the Apple Card export schema.

### Importing data

1. Look over `csv` example files in `import` dir, when done delete those

2. Put your import files into the `import` dir, matching the same schema

3. Update `banks.yaml` following the template there

4. Import

    ```shell
    rails db:seed:custom
    ```

## OpenShift

### Pipelines

1. Create secret with image repository credentials, something like:

    ```shell
    apiVersion: v1
    kind: Secret
    metadata:
      name: quay-creds  # this name is important
      namespace: finance
    data:
      .dockerconfigjson: randomlongstringhere
    type: kubernetes.io/dockerconfigjson
    ```

2. Create pipeline

    ```shell
    oc apply -f openshift/pipeline/pipeline.yaml
    ```

3. Create run

    ```shell
    oc create -f ./openshift/pipeline/pipeline-run.yaml
    ```
