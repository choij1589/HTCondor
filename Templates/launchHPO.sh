#!/bin/bash
export WORKDIR="/srv/work"
mkdir -p $WORKDIR/ParticleNet
mkdir -p $WORKDIR/ParticleNet/dataset/Skim3Mu__
cd $WORKDIR/ParticleNet

# Environment Setup
source /opt/conda/bin/activate
conda activate lxplus
xrdcp root://eosuser.cern.ch//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/archive/python.tar.gz $WORKDIR/ParticleNet
tar xf python.tar.gz
export PATH=$PATH:$PWD/python
export SYNETUNE_FOLDER=$PWD/syne-tune

# copy dataset
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/[CHANNEL]__/[SIGNAL]_vs_[BACKGROUND]_train.pt $WORKDIR/ParticleNet/dataset/[CHANNEL]__
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/[CHANNEL]__/[SIGNAL]_vs_[BACKGROUND]_valid.pt $WORKDIR/ParticleNet/dataset/[CHANNEL]__
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/[CHANNEL]__/[SIGNAL]_vs_[BACKGROUND]_test.pt $WORKDIR/ParticleNet/dataset/[CHANNEL]__

# run HPO
launchHPO.py --signal [SIGNAL] --background [BACKGROUND] --channel [CHANNEL]

# copy result config file back to EOS directory
xrdcp $WORKDIR/ParticleNet/results/[CHANNEL]/syne_tune_hpo/CSV/hpo_[SIGNAL]_vs_[BACKGROUND]_best_config.csv \
	  root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/condor/[JOBSCRIPT]/[CHANNEL]__/[SIGNAL]_vs_[BACKGROUND].best_config.csv
