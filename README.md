# auto_rnngine
Snakemake-driven pipeline for creating generative text models with tensorflow-char-rnn. Produces nice reports comparing models with various parameters.

# Recommended environment setup
- Spin up a g2.2xlarge (between 0.25 and 0.80 USD per hour) on EC2, using Deep Learning AMI with Conda (Ubuntu) (ami-f1e73689)
- Login as ubuntu
- pip install snakemake
- fix your conda activate/deactivate (mimicking https://github.com/conda/conda/pull/5407 , until 4.4.0 comes out)
- clone this repo
- create a config yaml (examples provided in config/)
- maybe start a screen or tmux session so you can leave it running in the background
- run the pipeline with ./run_pipeline.sh config/config_file.yaml
- enjoy your robo-babble

This is a personal project at the moment, documentation will be updated once it is in working condition, but please let me know if you have any ideas or needs!
