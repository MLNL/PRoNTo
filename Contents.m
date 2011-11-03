%
%
% Pattern Recognition for Neuroimaging Toolbox, aka. PRoNTo
% Verion 0.1 (PRoNTo) 30-November-2011
%__________________________________________________________________________
%
%     ____  ____        _   ________     
%    / __ \/ __ \____  / | / /_  __/_ 
%   / /_/ / /_/ / __ \/  |/ / / / __ \
%  / ____/ _, _/ /_/ / /|  / / / /_/ /
% /_/   /_/ |_|\____/_/ |_/ /_/\____/ 
%
%                              PRoNTO - http://www.mlnl.cs.ucl.ac.uk/pronto
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory
%
% $Id$
%
%__________________________________________________________________________
%
% PRoNTo v1 (2011) is the deliverable of a Pascal Harvest project 
% coordinated by Dr. Mourao-Miranda.
% PRoNTo is  developed by the Machine Learning & Neuroimaging Laboratory,
% Computer Science department, University College London, UK.
% http://www.mlnl.cs.ucl.ac.uk and associated researchers.
% 
% Main contributors, in alphabetical order: J. Ashburner, C. Chu, 
% A. Marquand, J. Mourao-Miranda, C. Phillips, J. Richiardi, J. Rondina, 
% M.J. Rosa, J. Schrouff,
% 
% The development of PRoNTo was possible with the financial and logistic 
% support of 
% - PASCAL Harvest Programme (http://www.pascal-network.org/)
% - the Department of Computer Science, University College London
%   (http://www.cs.ucl.ac.uk);
% - the Wellcome Trust;
% - PASCAL2 (http://www.pascal-network.org/) and its HARVEST programme;
% - the Fonds de la Recherche Scientifique-FNRS, Belgium
%   (http://www.fnrs.be);
% - Swiss National Science Foundation (PP00P2-123438) and Center for
%   Biomedical Imaging (CIBM) of the EPFL and Universities and Hospitals
%   of Lausanne and Geneva. 
%
% PRoNTo is written for MATLAB X.Y (R20ZZb) and onwards.
% Some routine may need to be compiled for your specific OS.
%
%__________________________________________________________________________
%
% PRoNTo is free software: you can redistribute it  and/or modify it under  
% the terms of the GNU General Public License as published by the Free 
% Software Foundation,  either version 2 of  the License,  or (at  your  
% option) any later version.
% PRoNTo is  distributed in the hope  that it will be  useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A  PARTICULAR PURPOSE.  See the  GNU General Public License   
% for more details.
% You should  have received a copy of the  GNU General Public License along
% with PRoNTo, in prt_LICENCE.man. If not, see 
% <http://www.gnu.org/licenses/>.
%
%__________________________________________________________________________
%
% List of files:
%   prt_batch - launch the PRoNTo batch system
%   prt_cfg_batch - (internal) add PRoNTo menu to batch system
%   prt_cfg_cv.m - 
%   prt_cfg_design - builds PRT.mat file containing data and design info
%   prt_cfg_kernel_construction - 
%   prt_cfg_preproc - 
%   prt_check_design -
%   prt_data_conditions -
%   prt_data_modality - 
%   prt_data_review - 
%   prt_defaults - 
%   prt_get_defaults - 
%   prt_get_filename - 
%   prt_load_blocks - 
%   prt_normalise_kernel - 
%   prt_preproc - XXX same as run_preproc
%   prt_remove_confounds - 
%   prt_run_cv - 
%   prt_run_design - 
%   prt_run_kernel_construction - 
%   prt_run_preproc - 
%   prt_text_input - 
%   prt_ui_design - 
%   prt_ui_main - 
