clc;
clear;
close all;

%% Loading dataset data

load('wider_face_train.mat');
% image = imread("WIDER_train\"+event_list{1}+"\"+cell2mat(file_list{1}(1))+".jpg");
%% Getting list of images with only one face and bounding box of that
c = 1;
for j = 1:size(event_list,1)
    for i = 1:size(face_bbx_list{j},1)
        if (size(face_bbx_list{j}{i},1) == 1 && (face_bbx_list{j}{i}(3) ~= 0))
            bbx(c,:) = double(face_bbx_list{j}{i}) + 1 ;
            name(c) = "WIDER_train\"+event_list{j}+"\"+cell2mat(file_list{j}(i))+".jpg";
            c = c+1;
        end
    end
end

%%  Scaling images

% Getting the scale factors ready
c = 1;
fsize = [19,20,21,22,23,24];
image_data = zeros(24,24,3,size(bbx,1)*12);
label = zeros(size(bbx,1)*12,1);

for i = 1:size(bbx,1)
    
        larger = double(max(bbx(i,3), bbx(i,4)));
        scale = larger./fsize;
        clear image
        clear image_c
        image_c = imread(name(i));
        image(:,:,1) = adapthisteq(image_c(:,:,1));
        image(:,:,2) = adapthisteq(image_c(:,:,2));
        image(:,:,3) = adapthisteq(image_c(:,:,3));
        [height, width, ~] = size(image);

%scaling the image
    if ( height > bbx(i,2)+bbx(i,4) )  && (width > bbx(i,1)+bbx(i,3))
    for j = 1:6 
        width_scaled = int32(ceil(width/scale(j)));
        height_scaled = int32(ceil(height/scale(j)));
        bbx_new = int32(ceil(bbx(i,:)./scale(j)));
        image_new = imresize(image, [height_scaled, width_scaled]);
        
        image_data(1:bbx_new(4),1:bbx_new(3),1:3,c) = uint8(image_new(bbx_new(2):bbx_new(2)+bbx_new(4)-1,bbx_new(1):bbx_new(1)+bbx_new(3)-1,:));
        imwrite(uint8(image_data(:,:,:,c)),sprintf('dataset\\%06d.jpg',c));
        label(c) = 1;
        c = c+1;
%         clear image_data;

% imshow(image_new(bbx_new(2):bbx_new(2)+bbx_new(4),bbx_new(1):bbx_new(1)+bbx_new(3),:));


        flag = 0;
        count = 0;
        while flag == 0
            y1 = ceil(rand(1) * width);
            x1 = ceil(rand(1) * height);
            if abs(y1 - bbx(i, 1))<20 && abs(x1 - bbx(i,2))<20 &&  ...
                    height-fsize(j)>y1 && width-fsize(j)>x1 && ...
                    y1>0 && x1 >0
                
                flag = 1;
            end
            count = count + 1;
            if (count > 10000 ) 
                flag = 1;
            end
        end
        
        if count<= 10000
            image_data(1:fsize(j),1:fsize(j),1:3,c) = uint8(image(y1:y1+fsize(j)-1,x1:x1+fsize(j)-1,:));
            imwrite(uint8(image_data(:,:,:,c)),sprintf('dataset\\%06d.jpg',c))
            label(c) = 0;
            c = c+1;
%             clear image_data;
        end
%         imshow(image_new(y1:y1+fsize(j),x1:x1+fsize(j),:));
        
    end
    end
end


%% Saving the output data
c = c-1;
save('Image_Data.mat','image_data');
save('Labels.mat','label');
save('Number_of_data.mat','c');
