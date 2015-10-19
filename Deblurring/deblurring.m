% created on 10/19/15
% http://yuzhikov.com/articles/BlurredImagesRestoration1.htm

imwrite(image, '7615_original.jpg');

%%
    I_raw = im2double(image);
    figure(1); imshow(I_raw); title('Source image');
%% try standard PSF

    PSF = fspecial('disk', 25);
    noise_mean = 0;
    noise_var = 0.0001;
    estimated_nsr = noise_var / var(I_raw(:));

    I_2 = edgetaper(I_raw, PSF);
    figure, imshow(deconvwnr(I_2, PSF, estimated_nsr));
%% try PSF in motion - works better
   
    PSF = fspecial('motion', 35, 0);
    noise_mean = 0;
    noise_var = 0.0001;
    estimated_nsr = noise_var / var(I_raw(:));

    I_2 = edgetaper(I_raw, PSF);
    I_new = deconvwnr(I_2, PSF, estimated_nsr);
    figure, imshow(I_new)

    