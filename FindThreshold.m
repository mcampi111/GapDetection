classdef FindThreshold < matlab.apps.AppBase
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

        % FindThreshold Properties%
        trial_number_max = 30;
        max_gap_ms = 100;
        decrease_inc_ms = 5;
        increase_inc_ms = 10;
        gap_ms = 60;
        Nb_Repeat_To_Stop = 2;
        min_detected_gap = inf;
    end
    methods
        function r = run(app, name, CalibValue, AxesRT)
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
            GP.init(app.trial_number_max);
            GP.applyCalibration(CalibValue);

            i=1;
            cptMin = 0;
            while (i < app.trial_number_max) && (app.gap_ms < app.max_gap_ms) && (app.gap_ms >= 0)
                GP.gap_duration = app.gap_ms;
                GP.playAskRandomGap(i,app.plot_graph,false,app.display_Duration);
                output_vector(end+1,:) = {i,GP.audioDeviceName,GP.tested_ear,GP.stim_duration,GP.used_noise,GP.ramp_type,GP.ramp_noise_duration,GP.ramp_gap_duration,GP.begin_gap_ms,GP.intensity_level_dB,GP.depth_gap_percent,GP.gap_duration,GP.answer,GP.answerDelay};
                switch GP.answer
                    case 1
                        if app.gap_ms == app.min_detected_gap
                            cptMin = cptMin+1;
                            if cptMin == app.Nb_Repeat_To_Stop
                                break;
                            end
                        end
                        if app.gap_ms < app.min_detected_gap
                            app.min_detected_gap = app.gap_ms;
                        end
                        app.gap_ms = app.gap_ms-app.decrease_inc_ms;

                    case 0
                        if app.gap_ms == app.min_detected_gap
                            app.min_detected_gap = app.min_detected_gap+app.decrease_inc_ms;
                        end
                        app.gap_ms = app.gap_ms+app.increase_inc_ms;

                    case -1
                        break;
                end
                i = i+1;
            end

            columnId = find(ismember(output_vector(1,:), 'gap Duration in ms'));
            gap_tested = cell2mat(output_vector(2:end,columnId));
            t = 1:size(gap_tested,1);
            plot(AxesRT, t, gap_tested);
            AxesRT.YLim = [0 app.max_gap_ms];
            AxesRT.XLim = [1 app.trial_number_max];

            [status, msg] = mkdir([pwd '\outFile']);
            filename = [pwd '\outFile\' char(datetime('now','TimeZone','local','Format','yyyy-MM-dd_HH-mm-ss')) '_' name '_threshold.csv'];
            writecell(output_vector,filename);
            r = gap_tested(end);
        end
    end
end