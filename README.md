# Finance Web

The way I'm doing forensics on my spending.

## Prerequisites

1. Ruby 3.4.5+

## Data Format

All data imported MUST follow the Apple Card export schema.

### Import

1. Look over example files in `import` dir, when done delete those

2. Put your import files into the `import` dir, matching the same schema

3. Import

    ```shell
    rails db:seed:custom
    ```
