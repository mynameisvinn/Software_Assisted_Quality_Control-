function [tileID] = CoordinatesToTileNumber(clickX, clickY, imageW, imageH)

imageLevels = 8;
magnificationLevel =9;

tileW = 1570;
tileH = 748;

if (magnificationLevel <= 0 || magnificationLevel > imageLevels)
    magnificationLevel =  imageLevels;
end;

tileW = uint64(tileW * power(2, imageLevels - magnificationLevel));
tileH = uint64(tileH * power(2, imageLevels - magnificationLevel));


cntTileX = uint64(ceil((double(imageW / tileW)))); 


xNum = uint64(floor(double(clickX / tileW)));
yNum = uint64(floor(double(clickY / tileH)));
tileID = xNum + yNum * cntTileX + 1;

end
