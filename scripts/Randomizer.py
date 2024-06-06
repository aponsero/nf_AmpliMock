#!/usr/bin/env python3

import itertools
import sys, getopt
import argparse
from numpy import random
from Bio import SeqIO

def get_args():
  parser = argparse.ArgumentParser(description='generates vectors for community simulation')
  parser.add_argument('-f', '--genomes', help='genome list file path',
    type=str, metavar='GENOMES', required=True)
  parser.add_argument('-t', '--taxa', help='Number of taxa to subset',
    type=int, metavar='TAXA', required=True)
  parser.add_argument('-o', '--output', help='output file',
    type=str, metavar='OUTPUT', required=False, default="subset.fasta")
  parser.add_argument('-m', '--max', help='max number of seq in fasta database',
    type=int, metavar='MAX', required=False, default=23588)

  return parser.parse_args()

def main():
    args = get_args()
    outfile= args.output
    mygenomes= args.genomes
    mytaxa= args.taxa
    mymax= args.max

    my_vec =random.randint(mymax, size=(mytaxa))
    fasta_selection = []
    taxonomy_selection = []

    with open(mygenomes) as handle:
        n=0
        for record in SeqIO.parse(handle, "fasta"):
            if n in my_vec :
                print("keep")
                print(record.id)
                fasta_selection.append(record)
                taxonomy_selection.append(record.id)
            n=n+1

    SeqIO.write(fasta_selection, outfile, "fasta")

    with open("subset_taxonomy.csv", 'w') as fp:
        fp.write("Domain;Proteobacteria;Class;Order;Family;Genus\n")
        for item in taxonomy_selection:
            fp.write("%s\n" % item)

if __name__ == "__main__":main()
