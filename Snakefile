#!/usr/bin/env python

import yaml
import json
import collections
from os.path import join, basename, dirname

# Check that a configuration file was provided
if not config:
    raise WorkflowError('No config file (--configfile) was provided, exiting.')

_default_config = yaml.load(open(srcdir('config/defaults/defaults.yaml')))

# Update the config dictionary without overwriting higher level
# https://stackoverflow.com/questions/3232943/update-value-of-a-nested-dictionary-of-varying-depth
def update(d, u):
    for k, v in u.items():
        if isinstance(v, collections.Mapping):
            d[k] = update(d.get(k, {}), v)
        else:
            d[k] = v
    return d

# Add any defaults that were not provided with config yaml
config = update(_default_config, config)

# Drop out if a data file was not provided for training
if "data_file" not in config['training'] :
    raise WorkflowError('No data file (traning: data_file) was provided, exiting.')

# Include rules file(s)
include: srcdir('rules/auto_rnngine.smk')

# Export configuration and objects to appropriate logfiles with each run
onstart:
    log_dir = os.path.join(os.getcwd(), 'log', 'run', str(config['run_number']))
    os.makedirs(log_dir, exist_ok=True)
    log_onstart = {'targets.log': '\n'.join(str(rules.all.input).split()),
                   'config.log': yaml.dump(config, default_flow_style=False),
                   'globals.log': str(globals()),
                   'locals.log': str(locals())}
    for logfile, log_string in log_onstart.items():
        logfile = os.path.join(log_dir, logfile)
        with open(logfile, 'w') as outh:
            print(log_string, file=outh)

            
# ############################
            
            
# Define workflow targets    
model_targets = expand(str(rules.sample_text.output.SOMETHING),
                       # training config
                       data_file=config['training']['data_file'],
                       data_name=config['training']['data_name'],
                       hidden_size=config['training']['hidden_sizes'],
                       num_layers=config['training']['num_layers'],
                       num_epochs=config['training']['num_epochs'],
                       learn_rate=config['training']['learn_rate'],
                       num_unrollings=config['training']['num_unrollings'],
                       model_type=config['training']['model_type'],
                       # sampling config
                       temperature=config['sampling']['temperatures'])
    
rule all:
    input: model_targets

# End of snakefile
    