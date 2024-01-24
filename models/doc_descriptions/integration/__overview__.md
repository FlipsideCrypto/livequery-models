# Flipside Crypto LiveQuery Models Integration Guide

Welcome to the comprehensive guide for integrating new models into Flipside Crypto's LiveQuery system!

## **Guide Overview**

This guide is designed to walk you through the process of integrating a new model into LiveQuery. It covers essential steps and provides helpful tips for a smooth integration.

### Integration Steps

#### 1. Model and Test Creation

Navigate to `models/deploy/marketplace/` and create a new folder named after your API. In this folder, you should create two essential files:

- `NAME-OF-YOUR-MODEL__.sql` - This file will contain your model code.
- `NAME-OF-YOUR-MODEL__.yml` - This file is for your model tests.

**Tip:** For guidance, refer to other models in the `models/deploy/marketplace` directory.

#### 2. Macro Creation

Within the same directory (`models/deploy/marketplace/`), create a new folder for your API and add the following file:

- `udfs.yaml.sql` - This file is where you'll define the macro that your model will execute. Structure it as follows:

  ```yaml
  - name: {{ schema_name -}}.<<api_method>>
    signature:
    - [QUERY, OBJECT, The GraphQL query]
    return_type:
    - "VARIANT"
    options: |
    COMMENT = $$Your comment$$
    sql: |
    SELECT
        live.udf_api(
        'GET',
        udf_object_to_url_query_string(<url>),
        {headers},
        {},
        '_FSC_SYS/SCHEMA_NAME'
    ) as response
  ```

#### 3. Deployment

Deploy your model following the standard deployment procedures.

- `dbt run -s models/deploy/marketplace/your_model/your_model__.sql -t dev --vars '{"UPDATE_UDFS_AND_SPS":True}'`

- `dbt test -s models/deploy/marketplace/your_model/your_model__.sql -t dev --vars '{"UPDATE_UDFS_AND_SPS":True}'`

#### Additional Tips:

- Ensure successful model runs. In case of errors, always refer to the log files for troubleshooting.
