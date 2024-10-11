## Development

1. cd your directory

    ```bash
    cd apps
    ```

2. Setup a virtual environment

    ```bash
    conda create -n "livequery-models" python=3.9
    ```

3. Activate the virtual environment

    ```bash
    conda activate livequery-models
    ```

4. Create a `.env` file from the env.sample file and run,

    ```base
    set -a; source .env; set +a
    ```

5. Install

    ```bash
    pip install -r ../requirements.txt
    ```

6. Add PYTHONPATH

    ```bash
    export PYTHONPATH=.
    ```

7. Run the app

    ```bash
    wave run app.py
    ```

7. Visit the demo at [http://localhost:10101/demo](http://127.0.0.1:10101/demo)
