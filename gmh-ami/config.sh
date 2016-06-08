#!/bin/bash

#Add julia repositories - if broken, check http://julialang.org/downloads/platform.html
sudo add-apt-repository -y ppa:staticfloat/juliareleases
sudo add-apt-repository -y ppa:staticfloat/julia-deps

#Update the repos, and install all required packages
#build-essential is used to build some of julia's packages
#hdf5-tools is used for loading and saving julia data files
sudo apt-get -y update
sudo apt-get -y install build-essential
sudo apt-get -y install hdf5-tools
sudo apt-get -y install julia

#Run a julia script that will install all julia's internal packages
julia -e 'include("julia-config.jl")'

#Contintue with finishing off the installation if all julia packages installed successfully
if [ $? -eq 1 ]; then
    echo 'The Julia configuration script for a GeneralizedMetropolisHastings AMI exited with errors' 1>&2
    echo 'The script has only been tested on a Ubuntu Server 14.04LTS AMI with Julia v0.4.x' 1>&2
else
    #Julia finished installing its internal packages and ran the tests, few things to finish off
    #Get the julia package directory and test if it exists
    JULIAPACKDIR=~/.julia
    if [ ! -d $JULIAPACKDIR ]; then
        echo "$JULIAPACKDIR directory not found... aborting" 1>&2
        exit 1
    fi
  
    #Get the current main version of the Julia installation
    JULIAVERSION=$( ls $JULIAPACKDIR | grep v[0-9]\.[0-9] )
    if [ ${#JULIAVERSION} -gt 6 ] #likely there is more than one version of Julia installed
    then
        echo "It seems there is more than 1 version of Julia installed. Trying... but this may go wrong"
    fi
    
    #Get the folder where the Jupyter server is installed
    JUPYTERBIN=$JULIAPACKDIR/$JULIAVERSION/Conda/deps/usr/bin
    if [ ! -d $JUPYTERBIN ]; then
        echo "$JUPYTERBIN directory not found... aborting" 1>&2
        exit 1
    fi
    
    #Test if the PATH variable has the Jupyter bin folder on it
    echo "$PATH" | grep -q "$JUPYTERBIN"
    if [ $? -eq 1 ]; then
        echo 'PATH="$PATH:/home/ubuntu/.julia/v0.4/Conda/deps/usr/bin"' >> ~/.profile
        source ~/.profile
    fi
    
    #Test again, if it's not been added to that path, throw an error
    echo "$PATH" | grep -q "$JUPYTERBIN"
    if [ $? -eq 1 ]; then
        echo "Adding $JUPYTERBIN to PATH did not produce the required result" 1>&2
        exit 1
    else
        echo "Jupyter directory $JUPYTERBIN successfully added to path"
    fi
    
    if [ ! -d ~/.jupyter ]; then
        mkdir ~/.jupyter
    fi
    
    if [ ! -d ~/.certificates ]; then
        mkdir ~/.certificates
    fi
    
fi
