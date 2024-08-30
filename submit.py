#!/usr/bin/python3
import os, shutil
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--jobscript", required=True, type=str, help="script name")
parser.add_argument("--channel", required=True, type=str, help="channel")
parser.add_argument("--signal", required=True, type=str, help="signal process")
parser.add_argument("--background", required=True, type=str, help="background process")
parser.add_argument("--no_exec", action="store_true", default=False, help="Only prepare submission scripts")
args = parser.parse_args()

# check argument
if args.jobscript not in ["launchHPO", "trainModels"]:
    raise ValueError(f"Wrong argument for jobscript {args.jobscript}")
if args.channel not in ["Combined", "Skim1E2Mu", "Skim3Mu"]:
    raise ValueError(f"Wrong argument for channel {args.channel}")
if args.signal not in ["MHc-100_MA-95", "MHc-130_MA-90", "MHc-160_MA-155"]:
    raise ValueError(f"Wrong argument for signal {args.signal}")
if args.background not in ["nonprompt", "diboson", "ttZ"]:
    raise ValueError(f"Wrong argument for background {args.background}")


def prepareSubmission(condor_base):
    # copy submit file
    with open(f"Templates/submit.jds", "r") as f:
        template = f.read()
    with open(f"{condor_base}/submit.jds", "w") as f:
        f.write(template.replace("[JOBSCRIPT]", args.jobscript).replace("[CHANNEL]", args.channel).replace("[SIGNAL]", args.signal).replace("[BACKGROUND]", args.background))

    # copy jobscript
    with open(f"Templates/{args.jobscript}.sh", "r") as f:
        template = f.read()
    with open(f"{condor_base}/{args.jobscript}.sh", "w") as f:
        f.write(template.replace("[JOBSCRIPT]", args.jobscript).replace("[CHANNEL]", args.channel).replace("[SIGNAL]", args.signal).replace("[BACKGROUND]", str(args.background)))

if __name__ == "__main__":
    WORKDIR = os.getcwd()
    CONDORBASE = f"{args.jobscript}/{args.channel}/{args.signal}_vs_{args.background}"
    try:
        os.makedirs(CONDORBASE)
    except Exception as e:
        raise e 
    print(f"@@@@ submitting jobs from {WORKDIR}...")
    print(f"@@@@ submitting {args.jobscript} with channel {args.channel}, signal {args.signal}, backgrond {args.background}...")
    prepareSubmission(CONDORBASE)
    os.chdir(CONDORBASE)
    if not args.no_exec:
        os.system("condor_submit submit.jds")
    os.chdir(WORKDIR)
