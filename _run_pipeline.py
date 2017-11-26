#!/usr/bin/env python3

import sys
import argparse
import yaml
from datetime import datetime
from subprocess import check_output
from os.path import join, dirname, basename, realpath
import os

# Define defaults
FIRST_RUN = 1
DEFAULT_JOB_NAME = 'run_' + basename(os.getcwd())
DEFAULT_SLEEP_TIME = 1
DEFAULT_LOGFILES = { # {{}} will become a number in run_snakemake
    'stdout_master_logfile': 'log/run/{num}/snakemake/{job_name}_master.out',
    'stderr_master_logfile': 'log/run/{num}/snakemake/{job_name}_master.err',
    'stdout_job_logfile': 'log/run/{num}/snakemake/{job_name}_jobs.out',
    'stderr_job_logfile': 'log/run/{num}/snakemake/{job_name}_jobs.err' # note that jobs logs are used in cluster contexts
}

# Echo some message and run a shell command, sleeping for some time prior
def echo_and_run(string, cmd, sleep=DEFAULT_SLEEP_TIME, quiet=False):
    print('{0} {1}'
          .format(string, ' '.join(cmd)), file=sys.stderr)
    check_output('sleep {}'.format(sleep), shell=True)
    stderr = open(os.devnull, 'wb') if quiet else sys.stderr
    check_output(cmd, shell=True, stderr=stderr)
    stderr.flush()

def _get_logfile(logfile, job_name, num):
    return join(os.getcwd(),
               (DEFAULT_LOGFILES[logfile]
                .format(job_name=job_name,
                        num=num)))

# Check log paths to see if runs have occurred. If so, use a higher run number
def infer_run_number(logfile, job_name):
    run_number = 1
    outfile = _get_logfile(logfile, job_name, run_number)
    while os.path.isfile(outfile):
        run_number += 1
        outfile = _get_logfile(logfile, job_name, run_number)
    return run_number

# Construct and run the snakemake command
def run_snakemake(opts, additional_args):
    # Infer run number from the last run stderr master logfile
    run_number = infer_run_number('stderr_master_logfile', opts.job_name)
    for logfile in DEFAULT_LOGFILES.keys():
        if opts.__dict__[logfile]:
            globals()[logfile] = opts.__dict__[logfile]
        else:
            output = _get_logfile(logfile, opts.job_name, run_number)
            globals()[logfile] = output
        os.makedirs(dirname(globals()[logfile]), exist_ok=True)

    snake_cmd = 'snakemake '
    snake_cmd += '--keep-going ' # Continue with independent tasks if a task fails
    snake_cmd += '--config '
    snake_cmd += '"run_number={}" '.format(run_number)
    snake_cmd += '--configfile {} '.format(opts.configfile[0])
#   snake_cmd += '-j 1 '.format(threads) # Use at most N cores in parallel (default: 1). If N is omitted, the limit is set to the number of available cores.
    snake_cmd += '-w 60 ' # Wait up to 60 seconds for output files
    snake_cmd += '--printshellcmds ' # Print out shell commands that will be executed
    snake_cmd += '--rerun-incomplete ' # Re-run all jobs the output of which is recognized as incomplete.
    snake_cmd += '--reason ' # Print the reason for each executed rule.
    snake_cmd += ''.join(['{} '.format(arg) for arg in additional_args])
#    snake_cmd += '-- {}'.format(' '.join(opts.targets))

    git_hash = check_output('git rev-parse HEAD', shell=True)
    git_branch = check_output('git rev-parse --abbrev-ref HEAD', shell=True)

    with open(stderr_master_logfile, 'w') as f:
        print('Executing Snakemake workflow... {}'.format(snake_cmd), file=f)
        for outh in (f, sys.stderr):
            print('Beginning Snakemake run in directory {dirname} '
                  'using git hash {hash} on branch {branch} at {time}.'
                  .format(dirname=os.getcwd(),
                          hash=git_hash,
                          branch=git_branch,
                          time=datetime.now()),
                  file=outh)

    echo_and_run('Running Snakemake...', [snake_cmd])

def get_arguments(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('configfile', nargs=1,
                        help='Path to the YAML configuration file.')
    parser.add_argument('-e', '--stderr-master-logfile', nargs='?')
    parser.add_argument('--stderr-job-logfile', nargs='?')
    parser.add_argument('--stdout-job-logfile', nargs='?')
    parser.add_argument('-o', '--stdout-master-logfile', nargs='?')
    parser.add_argument('--targets', nargs='+', type=str, default=['all'])
    parser.add_argument('--job-name', nargs='?', type=str, default=DEFAULT_JOB_NAME)
    return parser.parse_known_args(argv)


def main(argv):
    opts, additional_args = get_arguments(argv)
    run_snakemake(opts, additional_args)

if __name__ == '__main__':
    main(sys.argv[1:])
