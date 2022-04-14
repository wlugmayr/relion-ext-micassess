# Relion external MicAssess job support

These scripts can be called inside the [Relion](https://relion.readthedocs.io) user interface in the **External** jobs section. 
They setup a correct *Relion* directory structure and call the external [MicAssess](https://github.com/cianfrocco-lab/Automatic-cryoEM-preprocessing) program to assess the quality of **K3** movies.
After the micrograph assessment the scripts generate a Relion star file with good micrographs to continue with the CTF job step but also a filelist for cleanup of maybe not-good movies.

*MicAssess* can handle **float32** and **float16** micrographs.

These scripts have been tested with *Relion 3.1* and *4.0beta2* and *MicAssess 1.0*.

## Known limitations

 * All *MRC* files in *Relion* are organized in a **Movies** or **Micrographs** folder. The user guide provides examples how to link movies from a complex EPU folder into this structure.

## Installation

It is assumed that the *Relion* and *MicAssess* software is already installed and the pre-trained model files are downloaded from the original site.

1. Checkout the repository or download the bash scripts

2. Decide if you run the scripts *locally* on a workstation or *submit* the *MicAssess* job to a computing cluster. A working example from our SLURM cluster is provided. 

3. **Adapt** and **add** the settings from **env.source** file to your environment (e.g. **$HOME/.bashrc**). Alternatively you can **adapt** and **copy** the file **env.modules** to e.g. **$HOME/privatemodules/relion-ext-micassess** if you are using *environment modules*.

4. Put the bash script **relion_ext_micassess.sh** to **$PATH** like **/usr/local/bin** or choose it via the **Browse** button in Relion.

## User guide

A simple user guide can be found on [Relion MicAssess integration](https://confluence.desy.de/display/CCS/Relion+MicAssess+integration).


