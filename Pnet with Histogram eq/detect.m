clear;
clc;
close all;

%%

load("network.mat");

%%

% image_or = (imread('ttt.jpg'));
clear image
clear image_or
clear imagec
clear image_filter
image_or = imread('t3.jpg');
imagec(:, :, 1) = adapthisteq(image_or(:, :, 1));
imagec(:, :, 2) = adapthisteq(image_or(:, :, 2));
imagec(:, :, 3) = adapthisteq(image_or(:, :, 3));

scale = 14;
image = imresize(imagec, 1 / scale);

clear bbx
c = 1;

for i = 1:1:size(image, 1) - 12

    for j = 1:1:size(image, 2) - 12
        [f, score] = (classify(net, image(i:i + 11, j:j + 11, :)));

        if score(2) > 0.8
            bbx(:, :, c) = [i, j];
            %             score
            c = c + 1;
        end

    end

end

imshow(image_or)
hold on

for i = 1:size(bbx, 3)
    rectangle('Position', [bbx(1, 2, i) * scale, bbx(1, 1, i) * scale, scale * 12, scale * 12], 'Edgecolor', 'r');
end
