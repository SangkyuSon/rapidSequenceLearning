%% Information
% title              : Human hippocampal codes shift under feedback control during rapid sequence learning
% first author       : Sangkyu Son
% corresponding      : Seng Bum Michael Yoo, Sameer A. Sheth
% full author list   : see the manuscript
% inquiry about code : Sangkyu Son (ss.sangkyu.son@gmail.com)
%
% Tested on MATLAB R2022b (Update 2), Ubuntu 20.04.
% See README.md for system requirements, run times and expected output.

%% Set up
clearvars; close all; clc;
genDir     = pwd;                        % change this line to the folder holding main.m
utilDir    = fullfile(genDir,'utils');
computeDir = fullfile(genDir,'compute');
dataDir    = fullfile(genDir,'data');
addpath(genpath(utilDir))
addpath(genpath(computeDir))             % raw-data recomputation, used by draw_FigureX(dataDir,1)

%% Figures
draw_Figure1G(dataDir);    % Behavior, learning across repeated trials
draw_Figure2D(dataDir);    % Graded against sparse coding strength, cell by cell
draw_Figure2E(dataDir);    % Tuning of graded and sparse coding cells, before and after learning
draw_Figure3C(dataDir);    % Population trajectory in the first two principal components
draw_Figure3DG(dataDir);   % Population trajectory in the graded coding x reward plane
draw_Figure3EF(dataDir);   % Reward and graded coding subspace around a press
draw_Figure3H(dataDir);    % Reward against graded coding movement, cell by cell
draw_Figure4AB(dataDir);   % Population trajectory across learning stages, two PC bases
draw_Figure4C(dataDir);    % Distribution along the graded and sparse coding subspace
draw_Figure4D(dataDir);    % Subspace position across the four events of a sequence
draw_Figure4E(dataDir);    % Portion of subspace explained variance across learning stages
draw_Figure4FG(dataDir);   % Sensitivity of the two subspaces and their correlation
draw_Figure5DEFG(dataDir); % Network behaviour, lesion cost, control cost and efficiency
draw_Figure6AB(dataDir);   % Benefit per control cost when transferring to a new sequence

%% Supplementary figures
draw_SupplementaryFigure2(dataDir);   % Firing rate of each coding class against the rest
draw_SupplementaryFigure3(dataDir);   % Subspaces against principal components, and against each other
draw_SupplementaryFigure4(dataDir);   % Subspace axes before and after separating incorrect-ness
draw_SupplementaryFigure5(dataDir);   % Where the population goes after the last event of a sequence
