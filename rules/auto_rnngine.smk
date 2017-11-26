#!/usr/bin/env python

MODEL_DIR = 'models/{data_name}_{model_type}_hs{hidden_size}_nl{num_layers}_nu{num_unrollings}_lr{learn_rate}'

# globally define VENV2 param
# TODO need to locate environment and activation
globals()['VENV2'] = 'source activate {env} &&'.format(env='tensorflow_p27') # hardcoding for now

rule train_model:
    input:
        data_file = config['training']['data_file']
    output:
        results = MODEL_DIR + '/results.json'
    params:
        num_epochs = config['training']['num_epochs'],
        model_dir = MODEL_DIR
    shell:
        'mkdir -p models/ && '
        '{VENV2} python tensorflow-char-rnn/train.py '
        '--data-file {input.data_file} '
        '--output-dir {params.model_dir} '
        '--hidden-size {wildcards.hidden_size} '
        '--num-layers {wildcards.num_layers} '
        '--num-unrollings {wildcards.num_unrollings} '
        '--num-epochs {params.num_epochs} '
        '--learning-rate {wildcards.learn_rate} '
        '--log-to-file'

rule sample_text:
    input:
        sentinel = rules.train_model.output.results
    output:
        sample_txt = MODEL_DIR + '/samples/samples_temp{temperature}.txt'
    params:
        out_length = config['sampling']['out_length'],
        num_samples = config['sampling']['num_samples'],
        start_texts = config['sampling']['start_texts'],
        model_dir = MODEL_DIR
    run:
        # Create samples directory if it doesn't exist
        shell('mkdir -p {params.model_dir}/samples')
        sep = '----------------------'
        # Supply the base command so that samples are easy to get post hoc
        base_cmd = ('{VENV2} python tensorflow-char-rnn/sample.py '
        '--init-dir {rules.train_model.input.output_dir} '
        '--temperature {wildcards.temperature} '
        '--length {params.out_length} '
        '--start-text {wildcards.start_text} ')
        shell('echo "Base command: {base_cmd}\n{sep}" > {output.sample_txt}')
        for start_text in params.start_texts:
            shell('echo "STARTING TEXT: {start_text}\n{sep}" >> {output.sample_txt}')
            for samp_num in range(params.num_samples):
                shell('echo "SAMPLE {samp_num} {start_text}" >> {output.sample_txt}')
                shell(('{VENV2} python sample.py '
                '--init-dir {params.model_dir} '
                '--temperature {wildcards.temperature} '
                '--length {params.out_length} '
                '--start-text {wildcards.start_text} '
                '>> {output.sample_txt}'))
                shell('echo "{sep}" >> {output.sample_txt}')

        
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