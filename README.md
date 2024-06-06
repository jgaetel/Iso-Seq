# Iso-Seq assembly and functional annotation of full-length transcriptome of Sweet Cherry during dormancy

Firstly, Iso-Seq reads were submitted to three successive steps: establishing of circular consensus sequences (CCS), demultiplexing according to the Leishmania species and reﬁnement by using the command line IsoSeq v3 (v3.4.0), implemented in the IsoSeq GUI-based analysis application (SMRT Link v6.0.0). In order to generate one representative CCS for each transcript the zero-mode waveguide (ZMW) of the CCS (v6.4.0) program was used with the `--min-rq 0.9` parameter. Barcode demultiplexing and primer removal were performed using lima (version v1.10.0) with the `--isoseq` mode and `--peek-guess` parameter to remove spurious false positive signal. IsoSeq3 reﬁne (option `--require-polya`) was used to select those reads having a 3’-end adenine (A)-tract, after trimming out the poly(A) tails and concatemer identiﬁcation the FLNC transcripts were generated.

<img width="1000px" src="https://github.com/PacificBiosciences/IsoSeq/blob/master/doc/img/isoseq-clustering-end-to-end.png"/>

The working directory has the following structure:

```
Reg
└── Reg_Iso_bud
    ├── 1.rawdata
    ├── 2.ccs
    ├── 3.primer_removal
    ├── 4.refine
    └── 5.clustering
```
## Processing of raw PacBio Iso-Seq reads to FNLCs
### Step 1 - Circular Consensus Sequence (CCS) calling
Each sequencing run is processed by `ccs` to generate one representative circular consensus sequence (CCS) for each ZMW. Only ZMWs with at least one full pass (at least one subread with SMRT adapter on both ends) are used for the subsequent analysis.
Polished CCS subreads were generated, using CCS v.6.4.0, from the subreads bam files witha minimum quality of 0.9.
```bash
ccs --min-rq 0.9 -j 104 1.rawdata/m64083_230912_092706.subreads.bam 2.ccs0.9/m64083_230912_092706.ccs.bam
```

### Step 2 - Primer removal
Removal of primers and identification of barcodes is performed using [*lima*](https://github.com/pacificbiosciences/barcoding), which can be installed with `conda install lima` and offers a specialized `--isoseq` mode.
Even in the case that your sample is not barcoded, primer removal is performed by *lima*.
If there are more than two sequences in your `primer.fasta` file or better said more than one pair of 5' and 3' primers, please use *lima* with `--peek-guess` to remove spurious false positive signal.
More information about how to name input primer(+barcode) sequences in this [FAQ](https://github.com/pacificbiosciences/barcoding#how-can-i-demultiplex-isoseq-data).

```bash
lima -j 104 2.ccs0.9/m64083_230912_092706.ccs.bam ../../IsoSeqPrimers.fasta 3.primer_removal/output --isoseq
```

The consensus transcripts were mapped to the Sweet Cherry genome assembly using minimap2-2.17 (r941) (`-ax splice -uf –secondary = no –C5 –O6,24 –B4`) (Li, 2018). SAM ﬁles were sorted and used to collapse redundant isoforms using Cupcake v9.1.13. Unmapped and poorly mapped isoforms were used as input to Cogent v6.0.04 to reconstruct the coding genome. The reconstructed contigs were used as a fake genome to process and collapse the unmapped and poorly mapped reads through the ToFU pipeline.[^1]

### Step 3 - Refine
Remove polyA and concatemers from FL reads and generate FLNC transcripts (FL to FLNC)
```bash
isoseq refine -j 104 3.primer_removal/output.primer_5p--primer_3p.bam ../../IsoSeqPrimers.fasta 4.refine/Regina_bud.flnc.bam --require-polya
```

### Step 4 - Clustering
Cluster FLNC reads and generate transcripts, much faster than "cluster" (FLNC to TRANSCRIPTS)
```bash
isoseq cluster2 4.refine/flnc.fofn 5.clustering/Regina_leaf_clustered.bam
```

## Mapping Iso-Seq transcripts to Sweet Cherry genome assembly

```bash
minimap2 -ax splice:hq -uf final_markers.chr.fasta Regina_bud_leaf_isoforms.fa > Regina_isoforms_aln.sam
```

[^1]: Ali, A., Thorgaard, G. H., & Salem, M. (2021). PacBio Iso-Seq Improves the Rainbow Trout Genome Annotation and Identifies Alternative Splicing Associated With Economically Important Phenotypes. Frontiers in Genetics, 12, 683408. https://doi.org/10.3389/FGENE.2021.683408/BIBTEX
