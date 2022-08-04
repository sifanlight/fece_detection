clc;
clear;
close all;

%% Loading dataset data

load('wider_face_train.mat');
% image = imread("WIDER_train\"+event_list{1}+"\"+cell2mat(file_list{1}(1))+".jpg");
%% Getting list of images with only one face and bounding box of that
c = 1;

for j = 1:size(event_list, 1)

    for i = 1:size(face_bbx_list{j}, 1)

        if (size(face_bbx_list{j}{i}, 1) == 1 && (face_bbx_list{j}{i}(3) ~= 0))
            bbx(c, :) = double(face_bbx_list{j}{i}) + 1;
            name(c) = "WIDER_train\" + event_list{j} + "\" + cell2mat(file_list{j}(i)) + ".jpg";
            c = c + 1;
        end

    end

end

%%  Scaling images

% Getting the scale factors ready
c = 1;
fsize = [7, 8, 9, 10, 11, 12];
image_data = zeros(12, 12, 3, size(bbx, 1) * 12);
label = zeros(size(bbx, 1) * 12, 1);

for i = 1:size(bbx, 1)

    larger = double(max(bbx(i, 3), bbx(i, 4)));
    scale = larger ./ fsize;

    image = imread(name(i));
    [height, width, ~] = size(image);

    %scaling the image
    for j = 1:6
        width_scaled = int32(ceil(width / scale(j)));
        height_scaled = int32(ceil(height / scale(j)));
        bbx_new = int32(ceil(bbx(i, :) ./ scale(j)));
        image_new = imresize(image, [height_scaled, width_scaled]);

        image_data(1:bbx_new(4), 1:bbx_new(3), 1:3, c) = image_new(bbx_new(2):bbx_new(2) + bbx_new(4) - 1, bbx_new(1):bbx_new(1) + bbx_new(3) - 1, :);
        %         imwrite(image_data,sprintf('dataset\\%06d.jpg',c));
        label(c) = 1;
        c = c + 1;
        %         clear image_data;

        % imshow(image_new(bbx_new(2):bbx_new(2)+bbx_new(4),bbx_new(1):bbx_new(1)+bbx_new(3),:));

        flag = 0;
        count = 0;

        while flag == 0
            y1 = rand(1) * width_scaled;
            x1 = rand(1) * height_scaled;

            if abs(y1 - bbx_new(1)) < 6 && abs(x1 - bbx_new(2)) < 6 && ...
                    height_scaled - fsize(j) > y1 && width_scaled - fsize(j) > x1 && ...
                    y1 > 0 && x1 > 0

                flag = 1;
            end

            count = count + 1;

            if (count > 100)
                flag = 1;
            end

        end

        if count <= 100
            image_data(1:fsize(j), 1:fsize(j), 1:3, c) = image_new(y1:y1 + fsize(j) - 1, x1:x1 + fsize(j) - 1, :);
            %             imwrite(image_data,sprintf('dataset\\%06d.jpg',c))
            label(c) = 0;
            c = c + 1;
            %             clear image_data;
        end

        %         imshow(image_new(y1:y1+fsize(j),x1:x1+fsize(j),:));

    end

end

%% Saving the output data
c = c - 1;
save('Image_Data.mat', 'image_data');
save('Labels.mat', 'label');
save('Number_of_data.mat', 'c');
