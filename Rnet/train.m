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

val_image = image_data(:, :, :, c - 4999:c);
val_label = categorical(label(c - 4999:c));

auimds = augmentedImageDatastore([24 24 3], train_image, train_label);

%%

layers = [...
        imageInputLayer([24 24 3])
    convolution2dLayer(3, 28)
    reluLayer
    maxPooling2dLayer(3, 'Stride', 2)
    convolution2dLayer(3, 48)
    reluLayer
    maxPooling2dLayer(3, 'Stride', 2)
    convolution2dLayer(2, 64)
    reluLayer
    fullyConnectedLayer(128)
    reluLayer
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

net_R = trainNetwork(auimds, layers, opts);

%%

save('network_Rnet.mat', 'net_R');

%%
