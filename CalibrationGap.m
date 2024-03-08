classdef CalibrationGap < matlab.apps.AppBase
    properties
        % Properties comming from GUI%
        audioDeviceId = 0;
        Fs = 48000;
        used_noise = 'white';
        ramp_type = 'hanning';
        intensity_level_dB = 65;
        ramp_noise_duration = 20;

        % class properties %
        calibration_duration = 5000;
        calibration_level_L = 0;
        calibration_level_R = 0;
    end
    methods
        function r = run(app)
            GP = GapPresentation;
            GP.audioDeviceId = app.audioDeviceId;
            GP.Fs = app.Fs;
            GP.used_noise = app.used_noise;
            GP.ramp_type = app.ramp_type;
            GP.intensity_level_dB = app.intensity_level_dB;
            GP.ramp_noise_duration = app.ramp_noise_duration;
            
            GP.gap_duration = 0;
            GP.stim_duration = app.calibration_duration;
            GP.init(2);
            GP.tested_ear = 'Right';
            answ = questdlg('Place measurment system for calibration of RIGHT speaker then clic on Start. Be careful of the sound card and windows volume settings. The value defined here will became your maximum level', 'Calibration', 'Start','Start');
            if isempty(answ)
                %error('Exit button clicked during the calibration');
                r = [0;0];
                return;
            end
            GP.playRandomGap();
            app.calibration_level_L = str2double(inputdlg('Measured value in dB','Calibration'));
            if isempty(app.calibration_level_L)
                r = [0;0];
                return;
            end
            GP.tested_ear = 'Left';
            answ = questdlg('Place measurment system for calibration of LEFT speaker then clic on Start. Be careful of the sound card and windows volume settings. The value defined here will became your maximum level', 'Calibration', 'Start','Start');
            if isempty(answ)
                %error('Exit button clicked during the calibration');
                r = [0;0];
                return;
            end
            GP.playRandomGap();
            app.calibration_level_R = str2double(inputdlg('Measured value in dB','Calibration'));
            if isempty(app.calibration_level_R)
                r = [0;0];
                return;
            end
            r = [app.calibration_level_L;app.calibration_level_R];
        end
    end
end 