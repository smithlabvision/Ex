function frame = gaussNoise(nframes,pixelsize,len,rep)
    
    frame = zeros(len,len,nframes);

    len = len / pixelsize;
        
    for i = 1:nframes
        pixels = randn(len);
        thisframe = ...
            reshape(...
                    permute(...
                            repmat(...
                                   reshape(...
                                           repmat(...
                                                  reshape(pixels,1,len*len),...
                                                  [1,pixelsize,1] ...
                                                  ), ...
                                           size(pixels,1), ...
                                           len*pixelsize ...
                                           )', ...
                                    [1 1 pixelsize] ...
                                    ),...
                             [3 1 2] ...
                             ), ...
                     len*pixelsize, ...
                     len*pixelsize ...
                     );
        frame(:,:,i) = circshift(thisframe,floor(rand(2,1)*pixelsize));
    end
    
    m = max(max(max(abs(frame))));
    m = floor(frame * (127.99999/m)) + 128;
    clear frame
    
    frame = cell(nframes*rep,1);
    
    for i = 1:nframes
        for j = 1:rep
          
          f = uint8(m(:,:,i));
          frame{(i-1)*rep+j} = f;            
        end
    end

    