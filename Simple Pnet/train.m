clear;
clc;
close all;

%%

load("Image_Data.mat");
load("Labels.mat");
load("Number_of_data.mat");
%%

train_image = image_data(:, :, :, 1:c - 5000);
train_label = categorical(label(1:c - 5000));
% train_label = zeros(10000,2);
% for i = 1:10000
%     if label(i)==1
%         train_label(i,1) = 1;
%     else
%         train_label(i,2) = 1;
%     end
% end

val_image = image_data(:, :, :, c - 4999:c);
val_label = categorical(label(c - 4999:c));
% val_label = zeros(2000,1);
% c = 1;
% for i = 10001:12000
%     if label(i)==1
%         val_label(c,1) = 1;
%     else
%         val_label(c,2) = 1;
%     end
%     c = c+1;
% end

auimds = augmentedImageDatastore([12 12 3], train_image, train_label);

%%

layers = [...
        imageInputLayer([12 12 3])
    convolution2dLayer(3, 10)
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)
    convolution2dLayer(3, 16)
    reluLayer
    convolution2dLayer(3, 32)
    reluLayer
    convolution2dLayer(1, 2)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

%%
opts = trainingOptions('sgdm', ...
    'MaxEpochs', 30, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'Verbose', false, ...
    'ValidationData', {val_image, val_label});

net = trainNetwork(auimds, layers, opts);

%%

save('network.mat', 'net');

%%
