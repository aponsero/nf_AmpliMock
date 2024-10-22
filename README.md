# Amplimock-NF Pipeline

Amplimock-NF is a Nextflow pipeline for generating mock amplicon sequencing data. It utilizes various tools and custom scripts to simulate the entire process of amplicon sequencing, including generating mock comunity profiles, performing in silico PCR amplification, and simulating sequencing data.

## Overview

The pipeline consists of three main processes:

1. **PROFILE**: This process generates mock profiles using the `Randomizer.py` script. It randomly selects a specified number of taxa from a reference database and creates a mock profile FASTA file.

2. **CRABS**: This process runs CRABS (Cosmopolitan Robust Amplicon Bioinformatics) to perform in silico PCR amplification on the mock profile. It uses the provided forward and reverse primers to extract the amplicon regions from the mock profile sequences.

3. **INSILICO**: This process runs INSILICOSEQ to simulate amplicon sequencing data. It takes the amplicon sequences from the previous step and generates mock sequencing reads with user-specified parameters, such as sequencing depth, error model, and abundance distribution.

```mermaid
flowchart LR
    A[16S Database 
    & parameters] -->|Randomizer.py| B(Mock community 
    profile)
    B --> |CRABS|C(in silico 
    PCR amplicons)
    C --> |InSilicoSeq|D(in silico 
    amplicon sequences)
```

## Requirements

To run the Amplimock-NF pipeline, you need to have the following software installed:

- Nextflow v23.10.1
- Python 3
	- Biopython v1.83
	- numpy v1.26.4
- CRABS v0.1.1-0
- INSILICOSEQ v2.0.1-0

Additionally, you need to have a reference database (e.g., SILVA) for generating the mock profiles. Below are provided the instruction to download the SILVA v138 and the RDP v18 using the dada2 formated databases.

## Installation

### Conda environment installation

1. First, ensure that you have conda installed on your system. If not, you can download and install it from the official Anaconda website (https://www.anaconda.com/distribution/).

2. Open a terminal or command prompt.

3. Create a new conda environment with the desired name (e.g., `amplimock-env`) and install numpy, biopython and numpy:

```
conda create --name amplimock-env 
conda activate amplimock-env

conda install -c bioconda nextflow
conda install numpy
conda install -c conda-forge biopython
```

After executing these commands, you should have a conda environment named `amplimock-env` with Nextflow, NumPy, and Biopython installed. To verify the installations, you can run the following commands after activating the environment:

```
nextflow -version
python -c "import numpy; print(numpy.__version__)"
python -c "import Bio; print(Bio.__version__)"
```

These commands should print the version information for Nextflow, NumPy, and Biopython, respectively.

### Pipeline and database download

1. Download or clone the Amplimock-NF pipeline repository.
```
git clone git@github.com:aponsero/nf_AmpliMock.git
```

2. Download a reference amplicon database (e.g SILVA, or RefSeq amplicon datasets). The format should be a single fasta file with taxonomy ID or taxonomy name as sequence header. The (dada2 references databases)[https://benjjneb.github.io/dada2/training.html] are formated in this manner and can therefore be directly used by this pipeline:

```
mkdir databases
cd databases
# download SILVA v138
wget https://zenodo.org/records/4587955/files/silva_nr99_v138.1_train_set.fa.gz
gunzip silva_nr99_v138.1_train_set.fa.gz
# Download RDP v18
wget https://zenodo.org/records/4310151/files/rdp_train_set_18.fa.gz
gunzip rdp_train_set_18.fa.gz
```

## Usage

1. Navigate to the Amplimock-NF pipeline directory.

2. Modify the `nextflow.config` file to specify the required input parameters, such as the reference database path, number of taxa, output directory, and desired sequencing parameters.

3. Run the pipeline using conda the following command:
```
nextflow run amplimock.nf -profile conda
```
alternatively the pipeline can be used with Docker:
```
nextflow run amplimock.nf -profile docker
```
4. The pipeline will generate mock amplicon sequencing data in the specified output directory.


## Contributing

If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request in the Amplimock-NF pipeline repository.
