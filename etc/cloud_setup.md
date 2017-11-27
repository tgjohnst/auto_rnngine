Google recently lowered their prices on GPU instances, making them the obvious choice over AWS if you're willing to do a bit more setup. I decided to write up how I:

- Created an account and spun up a Google Compute Engine instance with an attached GPU for machine learning purposes
- Created a reusable machine image with pre-installed software so that it's easy to recreate instances ready to run things requiring tensorflow+Keras.

## Google compute advantages versus AWS for GPU instances

Prices here ...

## Creating an account and managing quotas

Sign up for GCE, ideally with the $300 free-tier credit offer at https://cloud.google.com/free/. 

Create a new project via the top bar if you don't want to work in 'My First Project'.

Google's GPU documentation is here and could be helpful if you get stuck: https://cloud.google.com/compute/docs/gpus/add-gpus

You'll need to increase your GPU quota in order to be allowed to attach a GPU to an instance. Visit the quotas page via the left navigation bar. Click the button at the top of the list to upgrade your account to be able to charge non-free tier items, otherwise you won't be able to increase your GPU quota. 

Request a quota increase for K80 GPUs in your region of choice by checking the box, then clicking 'Edit Quotas' at the top of the page. You'll be asked to provide a short justification. Starting out, you shouldn't need more than one or two GPUs, so don't go overboard, you can always add more later.

To be able to log in to an instance, you'll also want to store SSH keys. There are plenty of tutorials online for creating an SSH keypair. Once you have a keypair, upload it via the metadata page https://console.cloud.google.com/compute/metadata/ . All instances within the project will inherit that ssh key

## Configuring an instance

GCE -> VM Instances -> Create. 

See the screenshot below for settings. Adding 4 CPUs (15GB system RAM) and 100GB storage makes the total cost per instance ~$0.55/hr, still less than AWS for around twice the power. 

Launch the instance and wait for it to spin up. You can then ssh in using terminal  (nix) or PuTTY (Win). If you created your private key in PuTTY-gen, your username will be the same as the comment you saved with the key.

Elevate to root (`sudo su`) and install the Nvidia GPU drivers using the sample scripts located here: https://cloud.google.com/compute/docs/gpus/add-gpus . At the time I did it, the script was:

```bash
#!/bin/bash
echo "Checking for CUDA and installing."
# Check for CUDA and try to install.
if ! dpkg-query -W cuda-8-0; then
  # The 16.04 installer works with 16.10.
  curl -O http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
  dpkg -i ./cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
  apt-get update
  apt-get install cuda-8-0 -y
fi
```

To verify the drivers are working correctly after the installation completes, you can run the command `nvidia-smi` to verify your driver is installed and your GPU is properly detected.

To enable full acceleration of tensorflow, you'll also want to download the CuDNN 6.0 (important, use 6.0 not 7.0) packages from the Nvidia download site https://developer.nvidia.com/cudnn (you will need to create an account if you do not have one). Make sure you download the version compatible with your Ubuntu (16.04 in my case) and CUDA versions (8.0 in my case, retrieved using `cat /usr/local/cuda/version.txt`) Install the CuDNN for linux using 

```bash
tar -xzvf cudnn-8.0-linux-x64-v6.0.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn.h /usr/local/cuda/lib64/libcudnn*
```

Also, install the Runtime, and Developer debs provided using `sudo dpkg -i PACKAGENAME`

Install Anaconda3 (py3) from https://repo.continuum.io/archive/Anaconda2-5.0.1-Linux-x86_64.sh

Make a py2.7 and py3.5 evironment. If you want to maintain compatibility with AWS deeplearn image, you can call them tensorflow_p27 and tensorflow_p35. `conda create -n tensorflow_p35 python=3.5 anaconda`  `conda create -n tensorflow_p27 python=2.7 anaconda`

`source activate` your conda environment(s) and install tensorflow-gpu (2.7,3.5), keras (2.7,3.5), snakemake (3.5) via pip. Note that installing regular tensorflow won't install the gpu version...

## Creating a disk image

Now that we have everything installed, let's create a disk image so we don't have to do it again. 

- Stop the instance.
- In the instance list, click on the instance name itself; this will take you to the edit screen.
- Click the edit button, and then uncheck `Delete boot disk when instance is deleted`.
- Click the save button.
- Delete the instance, but double-check that `delete boot disk` is unchecked in the confirmation dialog.
- Now go to the `Images` screen and select `Create Image` with the boot disk as source.
