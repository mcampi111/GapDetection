classdef AudioTool < matlab.apps.AppBase
    properties
        % class properties %
        Devices;
        nbOutputDevices = 0;
        OutputDevices = {};
    end
    methods
        function r = listOutputDevicesName(app)
            app.Devices = audiodevinfo;
            app.nbOutputDevices = size(app.Devices.output,2);
            r = {app.Devices.output.Name};
        end
        function r = getOutputDevicesId(app)
            if ~isempty(app.Devices)
                r = {app.Devices.output.ID};
            end
        end
    end
end 