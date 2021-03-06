function stim_grating_alpha(optstr,w,objID,arg)
%function stim_grating(optstr,w,objID,arg)
%
% showex helper function for 'grating' stim class
%
% Each helper function has to have the ability to do 3 things:
% (1) parse the input arguments from the 'set' command and precompute
% anything that is necessary for that stimulus
% (2) issue the display commands for that object
% (3) clean up after that object is displayed (not always necessary)

global objects;
global sv;

if strcmp(optstr,'setup')
    a = sscanf(arg,'%i %f %f %f %f %i %i %i %f');
    
    % arguments: (1) frameCount
    %            (2) angle
    %            (3) initial phase
    %            (4) frequency
    %            (5) cycles per second
    %            (6) x position
    %            (7) y position
    %            (8) aperture size
    %            (9) contrast (0.0-1.0)
    
    angle = mod(180-a(2),360);
    f = a(4);
    cps = a(5);
    xCenter = a(6);
    yCenter = -a(7); % flip y coordinate so '-' is down
    rad= a(8); % Size of the grating image. Needs to be a power of two.
    contrast = a(9);
    
    % Calculate parameters of the grating:
    ppc=ceil(1/f);  % pixels/cycle
    fr=f*2*pi;
    visibleSize=2*rad+1;
    
    % Create a special texture drawing shader for masked texture drawing:
    %Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');
    
    phase = a(3)/360*ppc;
    
    % Create one single static grating image:
    x=meshgrid(-rad:rad + ppc, -rad:rad);
    grating = sv.gray + (sv.inc*cos(fr*x))*contrast;
    
    % Create circular aperture for the alpha-channel:
    [x,y]=meshgrid(-rad:rad, -rad:rad);
    circle = sv.white * (x.^2 + y.^2 <= (rad)^2);
    
    % Set 2nd channel (the alpha channel) of 'grating' to the aperture
    % defined in 'circle':
    grating(:,:,2) = 0;
    grating(1:2*rad+1, 1:2*rad+1, 2) = circle;
    
    % Store alpha-masked grating in texture and attach the special 'glsl'
    % texture shader to it:
    %gratingTex = Screen('MakeTexture', w, grating , [], [], [], [], glsl);
    gratingTex = Screen('MakeTexture', w, grating);
    
    % Create a single gaussian transparency mask and store it to a texture:
    %mask=ones(2*rad+1, 2*rad+1, 2) * mean(sv.bgColor);
    %[x,y]=meshgrid(-1*rad:1*rad,-1*rad:1*rad);
    
    %mask(:, :, 2)=sv.white * (sqrt(x.^2+y.^2) > rad);
    
    %maskTex=Screen('MakeTexture', w, mask);
    
    shift = cps * ppc * sv.ifi;
    
    dstRect=[0 0 visibleSize visibleSize];
    dstRect=CenterRect(dstRect, sv.screenRect) + [xCenter yCenter xCenter yCenter];
    stimname = mfilename;
    objects{objID} = struct('type',stimname(6:end),'frame',0,'fc',a(1), ...
        'angle',angle, 'phase',phase, 'shift', shift, ...
        'size',visibleSize, 'x',xCenter,'y',yCenter, ...
        'grating',gratingTex, ...
        'ppc',ppc, 'dstRect',dstRect,'textureShader',glsl);
elseif strcmp(optstr,'display')
    if isscalar(objects{objID}.shift) %added dynamic shift support (ACS20Feb2011)
        xOffset = mod(objects{objID}.frame*objects{objID}.shift+objects{objID}.phase,objects{objID}.ppc);
    else
        xOffset = mod(objects{objID}.shift(objects{objID}.frame+1)+objects{objID}.phase,objects{objID}.ppc); %don't multiply by frame b/c of cumsum in shiftFun -ACS20Feb2012
    end;
    
    srcRect = [xOffset 0 xOffset + objects{objID}.size objects{objID}.size];
    
    Screen('DrawTexture',w,objects{objID}.grating,[0 0 objects{objID}.size objects{objID}.size],objects{objID}.dstRect,objects{objID}.angle,[],[],[],objects{objID}.textureShader,[],[0,xOffset,0,0]);
    %Screen('DrawTexture',w,objects{objID}.mask,[0 0 objects{objID}.size objects{objID}.size],objects{objID}.dstRect,objects{objID}.angle);
elseif strcmp(optstr,'cleanup')
    Screen('Close',objects{objID}.grating);
    %Screen('Close',objects{objID}.mask);
else
    error('Invalid option string passed into stim_*.m function');
end
