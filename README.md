# auto_rnngine
Snakemake-driven pipeline for creating generative text models with tensorflow-char-rnn. Produces nice reports comparing models with various parameters.

# Recommended environment setup (more detailed instructions and non-EC2 instructions to come)
I recommend doing this on AWS EC2 or Google Compute Cloud if you don't have your own box with a beefy, CUDA-enabled GPU with plenty of memory. GPUs speed up training a lot, especially if you have a lot of hidden states.

As of 11/26/17:

EC2 g2.2xlarge range between 0.25 and 0.80 USD per hour, giving you access to 1 K520 GRID GPU with 4GB GPU memory. This is quite a bit slower than google's offering, but the AWS deep learning AMI does make things easier for beginners as everything is preinstalled and configured.

Google Compute just lowered GPU prices, they charge $0.45 for each K80 GPU attached to an instance. K80s have about 4x the compute cores (4992) and 4x the memory (24GB) as the K520, so it's pretty much a no-brainer to use google if possible.  They also offer $300 free credit for new users.

*If you are computing on the cloud, remember to stop your instances when you're not working with them or you'll rack up costs.*

## AWS EC2
- Spin up a g2.2xlarge  on EC2, using Deep Learning AMI with Conda (Ubuntu) (ami-f1e73689)
- Login as ubuntu
- pip install snakemake
- add ~/anaconda3/bin to your PATH
- fix your conda activate/deactivate scripts (mimicking https://github.com/conda/conda/pull/5407 , until 4.4.0 comes out

## Google Compute (these instructions apply for most other unix environments as well):
Coming soon


# Once you've set up the environment:
- clone this repo
- create a config yaml (examples provided in config/)
- maybe start a screen or tmux session so you can leave it running in the background
- run the pipeline with ./run_pipeline.sh config/config_file.yaml
- enjoy your robo-babble

This is a personal project at the moment, documentation will be updated once it is in working condition, but please let me know if you have any ideas or needs!

#Status:
- ~~Snakemake pipeline framework complete with standard YAML format~~
- ~~Training runs successfully on EC2~~
- ~~Sampling runs successfully on EC2~~
- Test and write up environment setup on google cloud
- Run pipeline successfully on google cloud
- Develop reporting scripts to compile results for each model
- Develop reporting scripts to assemble all model results for each run
- Implement cluster options and configuration to work with SGE in an HPC environment

#Datasets:
- Tiny shakespeare
- Hearthstone card names
- Soccer player names
- Beer names (OBDB)
