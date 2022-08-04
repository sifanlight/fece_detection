clear;
clc;
close all;

%%

load("network.mat");
load("network_Rnet.mat");

%%

% image_or = (imread('ttt.jpg'));
clear image
clear image_or
clear imagec
clear image_filter 
clear image_filtered 
blur = ones(9)/(9^2);
image_or = imread('t5.jpg');
image_or = imresize(image_or,[1024,1024]);
image_filtered = image_or;
imagec(:,:,1) = adapthisteq(image_or(:,:,1));
imagec(:,:,2) = adapthisteq(image_or(:,:,2));
imagec(:,:,3) = adapthisteq(image_or(:,:,3));
scales = [12,14];
figure('name','Rnet');
imshow(image_or)
hold on
for q = 1:length(scales)
scale = scales(q);
image = imresize(imagec,1/scale);   

clear bbx
c = 1;
for i = 1:1:size(image,1)-12
    for j = 1:1:size(image,2)-12
        [f,score] = (classify(net,image(i:i+11,j:j+11,:)));
        
        if score(2) > 0.6
            bbx(:,:,c) = [i,j];
%             score
            c = c+1;
        end
    end
end



% figure('name','Pnet');
% imshow(image_or)
% hold on
% for i=1:size(bbx,3)
%     rectangle('Position',[bbx(1,2,i)*scale, bbx(1,1,i)*scale,scale*12,scale*12],'Edgecolor', 'r');
% end
% hold off

c = 0;
clear box_f
for i = 1:size(bbx,3)
    im_input = imresize(imagec(bbx(1,1,i)*scale:bbx(1,1,i)*scale+12*scale,bbx(1,2,i)*scale:bbx(1,2,i)*scale+12*scale,:),[24 24]);
    [f,score] = classify(net_R,im_input);
    if (score(2) > 0.999)
        c = c+1;
        box_f(c) = i;
        
    end
    display(f);
    display(score);
end


for i=1:c
    rectangle('Position',[bbx(1,2,box_f(i))*scale, bbx(1,1,box_f(i))*scale,scale*12,scale*12],'Edgecolor', 'r');
    image_filtered(bbx(1,1,box_f(i))*scale:bbx(1,1,box_f(i))*scale+12*scale,bbx(1,2,box_f(i))*scale:bbx(1,2,box_f(i))*scale+12*scale,1:3) = imfilter(image_filtered(bbx(1,1,box_f(i))*scale:bbx(1,1,box_f(i))*scale+12*scale,bbx(1,2,box_f(i))*scale:bbx(1,2,box_f(i))*scale+12*scale,1:3),blur);
end
end
hold off

