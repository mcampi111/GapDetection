classdef PlotPsychometric < matlab.apps.AppBase
    properties
        % Generic Properties comming from GUI%
        audioDeviceId = 0;
        Fs = 48000;
        used_noise = 'white';
        ramp_type = 'hanning';
        tested_ear = 'Binaural';

        % Gap Properties comming from GUI%
        stim_duration = 800;
        gap_number = 1;
        ramp_noise_duration = 20;
        protect_gap_area = 30;
        ramp_gap_duration = 2;
        intensity_level_dB = 65;
        depth_gap_percent = 100;
        plot_graph = false;
        display_Duration = false;

        % PlotPsychometric Properties%
        trial_number = 100; %  > a nbRepeat (doit etre un modulo de trial number)
        nb_repeat = 10;
    end
    methods
        function r = run(app, name, rough_threshold, CalibValue, AxesPP)
            output_vector = {'trial Id','Audio Device','Ear','stim Duration in ms','used Noise','ramp Type','ramp Noise Duration in ms','ramp Gap Duration in ms','begin Gap in ms','intensity Level in dB','depth Gap Percent','gap Duration in ms','answer','answer Delay in ms'};
            GP = GapPresentation;
            GP.audioDeviceId = app.audioDeviceId;
            GP.Fs = app.Fs;
            GP.used_noise = app.used_noise;
            GP.ramp_type = app.ramp_type;
            GP.tested_ear = app.tested_ear;
            GP.stim_duration = app.stim_duration;
            GP.gap_number = app.gap_number;
            GP.ramp_noise_duration = app.ramp_noise_duration;
            GP.protect_gap_area = app.protect_gap_area;
            GP.ramp_gap_duration = app.ramp_gap_duration;
            GP.intensity_level_dB = app.intensity_level_dB;
            GP.depth_gap_percent = app.depth_gap_percent;
            GP.init(app.trial_number);
            GP.applyCalibration(CalibValue);

            max = rough_threshold*2;
            min = rough_threshold/4;
            stepSample = round((max-min)/(app.trial_number/app.nb_repeat-1)); %calculer l intervalle entre chaque echantillon
            min = max-((app.trial_number/app.nb_repeat-1)*stepSample);

            %faire une table qui va de min a max avec nbSample de chaque valeur
            sampleTable = zeros(1, app.trial_number);
            id = 1;
            for step = min:stepSample:max
                sampleTable(id:id+app.nb_repeat-1) = step;
                id = id + app.nb_repeat;
            end

            % randomiser l'odre de la table
            randomizedIndices = randperm(app.trial_number); % generer un vecteur d indices randomises 
            randomizedTable = sampleTable(randomizedIndices); % reorganiser la table selon les indices randomises 

            for i=1:app.trial_number
                GP.gap_duration = randomizedTable(i);
                GP.playAskRandomGap(i,app.plot_graph,true,app.display_Duration);
                output_vector(end+1,:) = {i,GP.audioDeviceName,GP.tested_ear,GP.stim_duration,GP.used_noise,GP.ramp_type,GP.ramp_noise_duration,GP.ramp_gap_duration,GP.begin_gap_ms,GP.intensity_level_dB,GP.depth_gap_percent,GP.gap_duration,GP.answer,GP.answerDelay};
            end

            %columnId = find(ismember(output_vector(1,:), 'gap Duration in ms'));
            %all_gap_tested = cell2mat(output_vector(2:end,columnId));
            columnId = find(ismember(output_vector(1,:), 'answer'));
            randomizedAnswer = cell2mat(output_vector(2:end,columnId));
            orderedAnswer(randomizedIndices) = randomizedAnswer;
            id = 1;
            for i=1:app.nb_repeat:app.trial_number
                answerPercent(id) = sum(orderedAnswer(i:i+app.nb_repeat-1))* 100 / app.nb_repeat;
                gap_tested(id) = sampleTable(i);
                id = id+1;
            end

            plot(AxesPP, gap_tested, answerPercent,'b--o');
            AxesPP.YLim = [0 100];
            AxesPP.XLim = [0 max];

            [status, msg] = mkdir([pwd '\outFile']);
            filename = [pwd '\outFile\' char(datetime('now','TimeZone','local','Format','yyyy-MM-dd_HH-mm-ss')) '_' name '_psycho.csv'];
            writecell(output_vector,filename);
            r = gap_tested(end);
        end
    end
end