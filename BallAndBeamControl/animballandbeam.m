function animballandbeam(block)
setup(block)
end
%% Local functions
function setup(block)
%
block.NumInputPorts  = 1;
block.NumOutputPorts = 0;
block.NumDialogPrms = 1;
block.NumDworks = 0;

% Register as scope block (i.e. will be skipped in codegen, input data will
% be streamed to host during rapid accelerator mode or external mode)
block.SetSimViewingDevice(true);

initializeUI()

block.RegBlockMethod('Update',@updateUI);
block.RegBlockMethod('Outputs',@updateNextHit);
end
%% Local functions
function initializeUI()
%%
global ballandbeamAttempt %#ok<GVMIS>

%% initialization
        % Basic dimensions.

        ballradius = 1;
        beamlength = 20;
        beamwidth = 0.3;

        % System parameters

        g = 0.05;                   % Gravitational Constant

        % Set initial conditions for ball and beam position

        x = beamlength/2;           % Initial Ball position

        % Setup controller with initial parameters

        xsp = x;                    % Initial setpoint
        
        
        % Create figure

        balldemo = figure( ...
            'Menubar','None',...
            'Name','Ball & Beam Demo', ...
            'NumberTitle','off', ...
            'BackingStore','off',...
            'CloseRequestFcn','delete(gcf)');

        % Create axes to hold ball & beam animation and plot

        bbAxes = axes(...
            'Units','normalized', ...
            'Position',[0.02 0.02 0.75 0.70],...
            'Visible','off',...
            'NextPlot','add');

        % Initialize animation axes

        axes(bbAxes);

        % Create Ball, keep handle
        a = 2*pi*(0:.05:.95)';
        xball = ballradius*sin(a);
        yball = ballradius*(1+cos(a));
        ballHndl = patch(xball+x,yball,1);

        % Create Beam
        xbeam = beamlength*[0 1 1 0]';
        ybeam = beamwidth*[0 0 -1 -1]';
        beamHndl = patch(xbeam,ybeam,2);

        % Create Fulcrum
        xpivot = [0 1 -1 0]';
        ypivot = [-beamwidth -5 -5 -beamwidth]';
        patch(xpivot,ypivot,3);

        % Create Setpoint Marker   
        xmarker = 3*beamwidth*[0 1 -1]';
        ymarker = 3*beamwidth*[0 -1 -1]'-beamwidth;
        markerHndl = patch(xmarker + xsp,ymarker,'r');

        set(balldemo, ...
            'UserData',[ballHndl beamHndl markerHndl]);
        % Draw

        axis equal
        axis([-1-2*ballradius, beamlength+2*ballradius, -5, 5 + ballradius]);
        drawnow;
end

function updateUI(block)
%%
global ballandbeamAttempt %#ok<GVMIS>

%% updates
        ballradius = 1;
        beamlength = 20;
        beamwidth = 0.3;
        xmin = 0;                   % Left limit
        xmax = beamlength;          % Right limit
        umin = -0.25;               % Minimum beam angle
        umax = 0.25;                % Maximum beam angle

        xbeam = beamlength*[0 1 1 0]';
        ybeam = beamwidth*[0 0 -1 -1]';
        % Create Ball, keep handle
        a = 2*pi*(0:.05:.95)';
        xball = ballradius*sin(a);
        yball = ballradius*(1+cos(a));
        % Create Setpoint Marker   
        xmarker = 3*beamwidth*[0 1 -1]';
        ymarker = 3*beamwidth*[0 -1 -1]'-beamwidth;

        balldemo = findobj(0,'Name','Ball & Beam Demo');
        tankHndlList = get(balldemo,'UserData');
        ballHndl = tankHndlList(1);
        beamHndl = tankHndlList(2);
        markerHndl = tankHndlList(3);
        input = block.InputPort(1).Data;
        u = max(min(input(1),umax),umin);
        x = input(2);
        xsp = input(3);
        if (x > xmin) && (x < xmax)
            
            % Update controller using current ball position
            % Last value of the control is in u
            % Current value of the state is in x

            % input(1) angulo input(2) posicion bola input(3) setpoint
            % Update Ball and Beam Animation

            set(beamHndl, ...
                'Xdata',cos(u)*xbeam - sin(u)*ybeam, ...
                'Ydata',sin(u)*xbeam + cos(u)*ybeam);
            set(ballHndl, ...
                'Xdata',cos(u)*(x + xball) - sin(u)*yball, ...
                'Ydata',sin(u)*(x + xball) + cos(u)*yball);
            set(markerHndl, ...
                'Xdata',cos(u)*(xsp + xmarker) - sin(u)*ymarker, ...
                'Ydata',sin(u)*(xsp + xmarker) + cos(u)*ymarker);
            drawnow;
        end

        if x < xmin
            x = xmin;
            set(ballHndl,'Xdata',x - 1 - ballradius + xball,'Ydata',yball-5);
        elseif x > xmax
            x = xmax;
            set(ballHndl,'Xdata',x + ballradius + xball,'Ydata',yball-5);
        end

        % Update Plot
        drawnow;
end

function updateNextHit(block)
%%
% ns stores the number of samples
t = block.CurrentTime;
ts = block.DialogPrm(1).Data;
ns = t/ts; % block.CurrentTime

% This is the time of the next sample hit.
block.NextTimeHit = (1 + floor(ns + 1e-13*(1+ns)))*ts;
end