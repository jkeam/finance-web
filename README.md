# Finance Web

The way I'm doing forensics on my spending.

## Prerequisites

1. Ruby 3.4.5+

## Data Format

All data imported MUST follow the Apple Card export schema.

### Import

1. Look over `csv` example files in `import` dir, when done delete those

2. Put your import files into the `import` dir, matching the same schema

3. Update `banks.txt` with your bank and credit card names, each on it's own line

4. Update `flip.txt` with the banks that need to be flipped to matched credit card deductions

5. Import

    ```shell
    rails db:seed:custom
    ```
