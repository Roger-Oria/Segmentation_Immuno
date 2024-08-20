clc
clear all
close all
%foder images
addpath('folder_path')
%folder images
cd 'folder_path'
listing = dir;
s = listing(arrayfun(@(x) ~strcmp(x.name(1),'.'),listing));

for i=1:length(s)
    
    file= fullfile('folder_path',s(i).name)
    %read images
    im= tiffreadVolume(file);
    %check size image
    sz=size(im);
    si=sz(1,1)*sz(1,2);
    %creates folder for every image
    [folder, baseFileNameNoExt, extension] = fileparts(file)
    filename = string(strcat('folder_path',baseFileNameNoExt));
    mkdir (filename)
    cd (filename)
    %Split images and channels + median filtered
    im1c1=im(1:((sz(1,1))),1:(sz(1,2)/2),1);
    im1a=medfilt2(im1c1,[2 2]);
    %Optional save images
    %imwrite(im1c1,'Im_L_c1','tiff','Compression','none')
    clear im1c1
    im1c3=im(1:((sz(1,1))),1:(sz(1,2)/2),3);
    im1b=medfilt2(im1c3,[2 2]);
    %Optional save images
    %imwrite(im1c3,'Im_L_c3','tiff','Compression','none')
    clear im1c3
    im2c1=im(1:((sz(1,1))),(1+(sz(1,2)/2)):(sz(1,2)),1);
    im2a=medfilt2(im2c1,[2 2]);
    %Optional save images
    %imwrite(im2c1,'Im_R_c1','tiff','Compression','none')
    clear im2c1
    im2c3=im(1:((sz(1,1))),(1+(sz(1,2)/2)):(sz(1,2)),3);
    im2b=medfilt2(im2c3,[2 2]);
    %Optional save images
    %imwrite(im2c3,'Im_R_c3','tiff','Compression','none')
    
    %Optional mask to remove background outside
    % figure()
    % imshow(im1b)
    % BW1=roipoly(im1b);
    % figure()
    % imshow(im1b)
    % BW2=roipoly(im2b)
    % BW1=immultiply(im1b,BW1);   
    % BW2=immultiply(im2b,BW2);
    BW1=imbinarize(im1b);
    BW2=imbinarize(im2b);
    stats1=regionprops(BW1,'Area')
    stats2=regionprops(BW2,'Area')
    % figure()
    % imshow(BW1)
    % figure()
    % imshow(BW2)
    %filename = string(strcat('stats_im_L','.mat'));
    %save(filename,'stats1')
    data=[stats1(:).Area];
    data1=sum(data);
    %Area of the section (Left) ddata1
    ddata1=(si/2)-data1;
    %filename = string(strcat('stats_im_R','.mat'));
    %save(filename,'stats2')
    clear data
    data=[stats2(:).Area];
    data2=sum(data);
    %Area of the section (Right) ddata2
    ddata2=(si/2)-data2;
    %imwrite(BW1,'mask1','tiff','Compression','none')
    %imwrite(BW2,'mask2','tiff','Compression','none')
    clear im 
    
    %Substract ch1 to ch3
    ii1=imsubtract(im1a,im1b);
    ii2=imsubtract(im2a,im2b);

    clear im1a im1b im2a im2b

    i1=double(ii1);
    i2=double(ii2);
    clear ii1 ii2
    
    %invert LUTs
    ia1=255-i1;
    ia2=255-i2;
    clear i1 i2

    B1a = max(ia1,0);
    B2a = max(ia2,0);
    clear ia1 ia2

    B1c=255-double(B1a);
    B2c=255-double(B2a);
    clear B1a B2a
    %transform to 8 bit image
    
    B1d=uint8(B1c);
    B2d=uint8(B2c);

    BW3=imbinarize(B1d);
    figure()
    imshow(BW3);
    % pause(5)
    % close()
    % 
    % ccc = input('Is it well  identified (y/n) ','s');
    % while ccc == 'n'
    % 
    %     xxx = input(['Adjust threshold ']);
    % 
    %     BW3=im2bw(B1d,xxx);
    %     figure()
    %     imshow(BW4);
    % ccc = input('Is it well  identified (y/n) ','s');
    % end
    
    %figure()
    %imshow(BW3);
    stats3_1=regionprops(BW3,'Area')
    %filename = string(strcat('stats_3_1','.mat'));
    %save(filename,'stats3_1')
    %imwrite(BW3,'mask3','tiff','Compression','none')
    clear data
    data=[stats3_1(:).Area];
    data=data(data>30);
    data3_1=sum(data)
    %xc3=corr2(B1d,BW3);
    
    BW4=imbinarize(B2d);
    figure()
    imshow(BW4);
    % pause(5)
    % close()
    % 
    % ccc = input('Is it well  identified (y/n) ','s');
    % while ccc == 'n'
    % 
    %     xxx = input(['Adjust threshold ']);
    % 
    %     BW4=im2bw(B2d,xxx);
    %     figure()
    %     imshow(BW4);
    % ccc = input('Is it well  identified (y/n) ','s');
    % end

    stats4_1=regionprops(BW4,'Area')
    %filename = string(strcat('stats_4_1','.mat'));
    %save(filename,'stats4_1')
    %imwrite(BW4,'mask4.tif')
    clear data
    data=[stats4_1(:).Area];
    data=data(data>30);
    data4_1=sum(data)
    %xc4=corr2(B2d,BW4);
    
    AA(i,1:6)=[data1 data2 ddata1 ddata2 data3_1 data4_1];
    %filename = string(strcat('Results','.mat'));
    %save(filename,'AA')
    imwrite(B1d,'image1','tiff','Compression','none')
    imwrite(B2d,'image2','tiff','Compression','none')
    close all
    clearvars -except s AA

end
