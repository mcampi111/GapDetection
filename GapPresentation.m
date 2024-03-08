classdef GapPresentation < matlab.apps.AppBase
    properties
        % Generic Properties comming from GUI%
        audioDeviceId = 10;
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

        % class properties %
        gap_duration = 0;
        level_correction_factor = [1,1];
        audioDeviceName;
        N;
        whiteNoise;
        ramp_noise_samples;
        ramp_gap_samples;
        protect_gap_sample;
        ramp_gap;
        ramp_noise;
        begin_gap;
        begin_gap_ms;
        answer;
        answerDelay;
        totalTrialNb;
        name;
        sound_to_play;
        envelop;
        depth_gap;
    end
    methods
        function r = init(app, totalTrialNb)
            app.totalTrialNb = totalTrialNb;
            support = audiodevinfo(0,app.audioDeviceId,app.Fs,16,2);
            if support == 0
                msg = ['Audio format not supported : ' app.audioDeviceId ' at ' app.Fs 'Hz'];
                errordlg(msg,'Error');
                return
            end
            app.audioDeviceName = audiodevinfo(0,app.audioDeviceId);
            app.N = round(app.Fs*(app.stim_duration/1000));
            app.whiteNoise = dsp.ColoredNoise(app.used_noise, app.N, 1);
            rng('shuffle'); % radomize the rand generator

            app.ramp_noise_samples = (app.ramp_noise_duration/1000) * app.Fs;
            app.ramp_gap_samples = (app.ramp_gap_duration/1000) * app.Fs;
            app.protect_gap_sample = (app.protect_gap_area/1000) * app.Fs;

            app.depth_gap = app.depth_gap_percent/100;
            switch app.ramp_type
                case 'linear'
                    tempramp = linspace(1-app.depth_gap, 1, app.ramp_gap_samples);
                    app.ramp_gap = tempramp(1:app.ramp_gap_samples);
                    tempramp = linspace(0, 1, app.ramp_noise_samples);
                    app.ramp_noise = tempramp(1:app.ramp_noise_samples);
                case 'hanning'
                    tempramp = hann(app.ramp_gap_samples*2)';
                    app.ramp_gap = fliplr(1-(tempramp(1:app.ramp_gap_samples)*app.depth_gap));
                    tempramp = hann(app.ramp_noise_samples*2)';
                    app.ramp_noise = tempramp(1:app.ramp_noise_samples);
                otherwise
                    errordlg('Unexpected ramp type','Error');
                    return
            end
            r = app;
        end

        function applyCalibration(app, calibValue)
            if app.intensity_level_dB > min(calibValue)
                errordlg('The target power is greater than that defined during calibration','Error');
                app.level_correction_factor = [0,0];
                return
            end
            app.level_correction_factor = [10^((app.intensity_level_dB-calibValue(1))/20), 10^((app.intensity_level_dB-calibValue(2))/20)];
        end

        function playGap(app, gapPosition)
            gap_samples = (app.gap_duration/1000) * app.Fs;
            gap_area_sample = app.N - (app.gap_number*gap_samples) ...
                - (2*app.ramp_noise_samples)  ...
                - (2*app.gap_number*app.ramp_gap_samples) ... 
                - ((app.gap_number+1)*app.protect_gap_sample); %stim_duration - x*gap_duration - 2*ramp_noise_duration - x*2*ramp_gap_duration - (x+1)*protect_gap_area
                gap_area_sample = gap_area_sample/app.gap_number;
            
            sound = app.whiteNoise()';
            sound = sound./(max(abs(max(sound)),abs(min(sound)))); % normalize the noise

            app.envelop = ones(1,app.N); % Define envelop
            app.envelop(1:app.ramp_noise_samples) = app.ramp_noise; %Fade in
            app.begin_gap = zeros(app.gap_number,1);
            if app.gap_duration > 0
                for gapNb=1:(app.gap_number)
                        app.begin_gap(gapNb) = gapPosition ...
                        + app.ramp_noise_samples ...
                        + (2*(gapNb-1)*app.ramp_gap_samples) ...
                        + ((gapNb-1)*gap_samples) ...
                        + ((gapNb-1)*gap_area_sample) ...
                        + (gapNb*app.protect_gap_sample);
                    app.envelop((app.begin_gap(gapNb)+1):(app.begin_gap(gapNb)+app.ramp_gap_samples)) = fliplr(app.ramp_gap); %Fade in Gap
                    app.envelop((app.begin_gap(gapNb)+app.ramp_gap_samples):(app.begin_gap(gapNb)+app.ramp_gap_samples+gap_samples)) = 1-app.depth_gap; % Gap
                    app.envelop((app.begin_gap(gapNb)+app.ramp_gap_samples+gap_samples+1):(app.begin_gap(gapNb)+2*app.ramp_gap_samples+gap_samples)) = app.ramp_gap; %Fade out Gap
                end
            end
            app.begin_gap_ms = round((app.begin_gap/app.Fs) * 1000);
            app.envelop((app.N-app.ramp_noise_samples+1):end) = fliplr(app.ramp_noise);  % Fade out
            
            % Apply envelop on sound
            sound_with_gap = sound.*app.envelop;
            switch app.tested_ear
                case 'Right'
                    app.sound_to_play = [zeros(1,app.N); sound_with_gap.*app.level_correction_factor(2)];
                case 'Left'
                    app.sound_to_play = [sound_with_gap.*app.level_correction_factor(1); zeros(1,app.N)];
                case 'Binaural'
                    app.sound_to_play = [sound_with_gap.*app.level_correction_factor(1); sound_with_gap.*app.level_correction_factor(2)];
                otherwise
                    msg = ['Unexpected Ear : ' app.tested_ear];
                    errordlg(msg,'Error');
                    return
            end
            
            % Play sound
            player = audioplayer(app.sound_to_play,app.Fs,16,app.audioDeviceId);
            playblocking(player);
        end

        function playFixedGap(app, gapPositionms)
            app.playGap(round(gapPositionms*app.Fs/1000))
        end

        function playRandomGap(app)
            gap_samples = (app.gap_duration/1000) * app.Fs;
            gap_area_sample = app.N - (app.gap_number*gap_samples) ...
                - (2*app.ramp_noise_samples)  ...
                - (2*app.gap_number*app.ramp_gap_samples) ... 
                - ((app.gap_number+1)*app.protect_gap_sample); %stim_duration - x*gap_duration - 2*ramp_noise_duration - x*2*ramp_gap_duration - (x+1)*protect_gap_area
                gap_area_sample = gap_area_sample/app.gap_number;

            app.playGap(floor(rand()*gap_area_sample));
        end

        function r = playAskRandomGap(app, trialNb, PlotGraph, dispNbTrial, dispDuration)
            app.playRandomGap();
            tic;

            tempstring = 'Trial ';
            % Wait for reply
            if dispNbTrial == true
                tempstring = [tempstring num2str(trialNb) '/' num2str(app.totalTrialNb) ' '];
            end
            if dispDuration == true
                tempstring = [tempstring num2str(app.gap_duration) 'ms '];
            end
            tempstring = [tempstring ': '];
            
            answ = questdlg(tempstring, 'Did you ear the gap?', 'Yes','No','No');
            app.answerDelay = round(toc*1000);
            switch answ
                case 'Yes'
                    app.answer = 1;
                case 'No'
                    app.answer = 0;
                otherwise
                    app.answer = -1;
                    return
            end

            if PlotGraph
                t = linspace(0, length(max(app.sound_to_play))/app.Fs, length(max(app.sound_to_play)));
                figure;
                hold on
                    plot(t, app.sound_to_play);
                hold off
                xlabel('Time (s)');
                ylabel('Normalized amplitude');
                title('Sound Signal');
            end
            r = app;
        end
    end
end