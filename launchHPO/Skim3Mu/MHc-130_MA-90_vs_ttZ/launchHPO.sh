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
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/Skim3Mu__/MHc-130_MA-90_vs_ttZ_train.pt $WORKDIR/ParticleNet/dataset/Skim3Mu__
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/Skim3Mu__/MHc-130_MA-90_vs_ttZ_valid.pt $WORKDIR/ParticleNet/dataset/Skim3Mu__
xrdcp root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/dataset/Skim3Mu__/MHc-130_MA-90_vs_ttZ_test.pt $WORKDIR/ParticleNet/dataset/Skim3Mu__

# run HPO
launchHPO.py --signal MHc-130_MA-90 --background ttZ --channel Skim3Mu

# copy result config file back to EOS directory
xrdcp $WORKDIR/ParticleNet/results/Skim3Mu/syne_tune_hpo/CSV/hpo_MHc-130_MA-90_vs_ttZ_best_config.csv \
	  root://eosuser.cern.ch:1094//eos/user/c/choij/ChargedHiggsAnalysisV2/ParticleNet/condor/launchHPO/Skim3Mu__/MHc-130_MA-90_vs_ttZ.best_config.csv
