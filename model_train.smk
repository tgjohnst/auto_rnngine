# todo add snakemake to python / env.


# set up snakemake config here.
config = #TODO

# globally define VENV2 param
# TODO need to locate environment and activation
globals()[param] = ('source {activate} {env} &&'
                    .format(activate=srcdir('../env/lib/miniconda3/bin/activate'),
                        env=env))

rule train_model:
    input:
        data_file = 'data/{data_file}'
    output:
        finished = 'models/{wildcards.data_name}_hs{wildcards.hidden_size}_nl{wildcards.num_layers}_lr{wildcards.learn_rate}/TODO'
        # TODO how do we extract dir from this?
    params:
    shell:
        '{VENV2} python train.py '
        '--data-file {input.data_file} '
        '--output-dir models/{wildcards.data_name}_hs{wildcards.hidden_size}_nl{wildcards.num_layers}_nu{wildcards.num_unrollings}_lr{wildcards.learn_rate}/ '
        '--hidden-size {wildcards.hidden_size} '
        '--num-layers {wildcards.num_layers} '
        '--num-unrollings {wildcards.num_unrollings} '
        '--num-epochs {wildcards.num_epochs} '
        '--learning-rate {wildcards.learn_rate} '
        # todo optional touch sentinel to mark finished?

rule sample_text:
    input:
        sentinel = rules.train_model.output.finished
    output:
        _temp{temperature}_
    params:
        out_length=config['sampling']['out_length'],
        num_samples=config['sampling']['num_samples'],
        start_texts=config['sampling']['start_texts']
#Define VENV2 command
    run:
        #TODO create output file
        #TODO write metadata line to output file
        # for temp in params.temperatures:
        #  for start_text in params.start_texts:
        #   for i in 1:params.num_samples:
        shell('{VENV2} python sample.py ' +
        '--init-dir {rules.train_model.input.output_dir} ' +
        '--temperature {wildcards.temperature} ' +
        '--start-text {wildcards.start_text} ' +
        '--seed {wildcards.seed} ' +
        '--length {params.out_length} ' +
        '>> {output.}')
        #  figure out a way to present side-by-side
        #  the results of a bunch of start texts and temps
        #  so that optimal parameters and breakdowns can be determined
        #  maybe an ipynb or compile into a webpage with fixed format 
        
rule compile_model_report_json:
    input:
        rules.sample_text.output.log # TODO
    output:
        report = #REPORTOUT TODO

rule compile_meta_report_json:
    input:
        data_file = 'data/{data_file}',
        data_chars_to_display = config['reporting']['data_preview_len']
        #TODO config file path? how do we go get it?
        
    output:
        
    run:
        
#TODO create per-model report template JSON

rule assemble_reports:
    input:
        meta_report = rules.compile_meta_report_json.output
        model_reports = expand(rules.compile_model_report_json.output.____ #TODO
    output:
        compiled_reports = #TODO
        
#compile into a big old json! 
#TODO write a json2html transform function!
#TODO write a json2html output CSS to render more prettily
#  this can come after the basic transform is complete.
    
model_targets = expand(str(rules.sample_text.output.SOMETHING),
                       # training config
                       data_file=config['training']['data_file'],
                       data_name=config['training']['data_name'],
                       hidden_size=config['training']['hidden_sizes'],
                       num_layers=config['training']['num_layers'],
                       num_epochs=config['training']['num_epochs'],
                       learning_rate=config['training']['learn_rate'],
                       num_unrollings=config['training']['num_unrollings'],
                       # sampling config
                       temperature=config['sampling']['temperatures'])
    
rule all:
    input: model_targets