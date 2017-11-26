# todo add snakemake to python / env.

MODEL_DIR = 'models/{wildcards.data_name}_{wildcards.model_type}_hs{wildcards.hidden_size}_nl{wildcards.num_layers}_lr{wildcards.learn_rate}'

# globally define VENV2 param
# TODO need to locate environment and activation
globals()['VENV2'] = 'source activate {env} &&'
                    .format(env='tensorflow_p27') # hardcoding for now

rule train_model:
#    input:
#        data_file = '{data_file}'
    output:
        finished = MODEL_DIR + '/completion_sentinel',
        results = MODEL_DIR + '/results.json'
        # TODO how do we extract dir from this?
    params:
        data_file = wildcards.data_file # this should be an input?
    shell:
        '{VENV2} python train.py '
        '--data-file {input.data_file} '
        '--output-dir models/{wildcards.data_name}_hs{wildcards.hidden_size}_nl{wildcards.num_layers}_nu{wildcards.num_unrollings}_lr{wildcards.learn_rate}/ '
        '--hidden-size {wildcards.hidden_size} '
        '--num-layers {wildcards.num_layers} '
        '--num-unrollings {wildcards.num_unrollings} '
        '--num-epochs {wildcards.num_epochs} '
        '--learning-rate {wildcards.learn_rate} '
        '&& touch {output.finished}' # touch a sentinel file to indicate completion

rule sample_text:
    input:
        sentinel = rules.train_model.output.finished
    output:
        sample_text = MODEL_DIR + '/samples/samples_temp{temperature}.txt'
    params:
        out_length=config['sampling']['out_length'],
        num_samples=config['sampling']['num_samples'],
        start_texts=config['sampling']['start_texts']
    run:
        # Create samples directory if it doesn't exist
        shell('mkdir -p {MODEL_DIR}/samples')
        sep = '----------------------'
        # Supply the base command so that samples are easy to get post hoc
        base_cmd = '{VENV2} python sample.py ' +
        '--init-dir {rules.train_model.input.output_dir} ' +
        '--temperature {wildcards.temperature} ' +
        '--length {params.out_length} ' +
        '--start-text {wildcards.start_text} '
        shell('echo "Base command: {base_cmd}\n{sep}" > {output.sample_text}')
        for start_text in params.start_texts:
            shell('echo "STARTING TEXT: {start_text}\n{sep}" >> {output.sample_text}')
            for samp_num in range(params.num_samples):
                shell('echo "SAMPLE {samp_num} {start_text}" >> {output.sample_text}')
                shell('{VENV2} python sample.py ' +
                '--init-dir {rules.train_model.input.output_dir} ' +
                '--temperature {wildcards.temperature} ' +
                '--length {params.out_length} ' +
                '--start-text {wildcards.start_text} ' +
                '>> {output.}')
                shell('echo "{sep}" >> {output.sample_text}')

        
# rule compile_model_report_json:
    # input:
        # rules.sample_text.output.log # TODO
    # output:
        # report = #REPORTOUT TODO

# rule compile_meta_report_json:
    # input:
        # data_file = 'data/{data_file}',
        # data_chars_to_display = config['reporting']['data_preview_len']
        # #TODO config file path? how do we go get it?
        
    # output:
        
    # run:
        
  # #TODO create per-model report template JSON

# rule assemble_reports:
    # input:
        # meta_report = rules.compile_meta_report_json.output
        # model_reports = expand(rules.compile_model_report_json.output.____ #TODO
    # output:
        # compiled_reports = #TODO
        
#compile into a big old json! 
#TODO write a json2html transform function!
#TODO write a json2html output CSS to render more prettily
#  this can come after the basic transform is complete.
    
model_targets = expand(str(rules.sample_text.output.sample_text),
                       # training config
                       data_file=config['training']['data_file'],
                       data_name=config['training']['data_name'],
                       model_type=config['training']['model_type'],
                       hidden_size=config['training']['hidden_sizes'],
                       num_layers=config['training']['num_layers'],
                       num_epochs=config['training']['num_epochs'],
                       learn_rate=config['training']['learn_rate'],
                       num_unrollings=config['training']['num_unrollings'],
                       # sampling config
                       temperature=config['sampling']['temperatures'])
    
rule all:
    input: model_targets