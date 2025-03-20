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
Polished CCS subreads were generated, using CCS v.6.4.0, from the subreads bam files witha minimum quality of 0.99 (default).
(See: [How does CCS work](https://ccs.how/how-does-ccs-work.html))
```bash
ccs -j <threads> 1.rawdata/m64083_230912_092706.subreads.bam 2.ccs/m64083_230912_092706.ccs.bam
```
<img width="500px" src="https://ccs.how/img/ccs-workflow.png"/>

### Step 2 - Primer removal
Removal of primers and identification of barcodes is performed using [*lima*](https://github.com/pacificbiosciences/barcoding), which can be installed with `conda install lima` and offers a specialized `--isoseq` mode.
Even in the case that your sample is not barcoded, primer removal is performed by *lima*.
If there are more than two sequences in your `primer.fasta` file or better said more than one pair of 5' and 3' primers, please use *lima* with `--peek-guess` to remove spurious false positive signal.
More information about how to name input primer(+barcode) sequences in this [FAQ](https://github.com/pacificbiosciences/barcoding#how-can-i-demultiplex-isoseq-data).

```bash
lima -j <threads> 2.ccs/m64083_230912_092706.ccs.bam ../../IsoSeqPrimers.fasta 3.primer_removal/output --isoseq
```



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


 ### Step 5 - Mapping
```bash
pbmm2 index -j 104 --preset ISOSEQ final_markers.chr.fasta final_markers.chr.mmi
pbmm2 align -j 104 --sort --preset ISOSEQ final_markers.chr.mmi ../5.clustering/Regina_bud_clustered.bam Regina_bud_aln.bam
```

### Step 6 - Collapsing
After transcript sequences are mapped to a reference genome, isoseq collapse can be used to collapse redundant transcripts (based on exonic structures) into unique isoforms. Output consists of unique isoforms in GFF format and secondary files containing information about the number of reads supporting each unique isoform. [Source](https://isoseq.how/classification/isoseq-collapse.html)

- **Collapse examples**
<img width="1000px" src="https://isoseq.how/img/collapse.png"/>

```bash
isoseq collapse -j 104 --do-not-collapse-extra-5exons ../6.mapping/Regina_bud_aln.bam Regina_bud.gff
```
- **Collapsing extra 5p exons**

For applications like single-cell Iso-Seq where there is a higher percentage of 5p truncated isoforms, it is useful to collapse isoforms that have a matching exon structure with the exception of extra 5p exons. Previous versions of collapse did not merge isoforms with extra 5p exons. As of v3.8.0, collapse will merge these isoforms by default. **To not allow merging isoforms with extra 5p exons**, use `--do-not-collapse-extra-5exons`. This option is used in the bulk Iso-Seq workflow.

<img width="1000px" src="https://isoseq.how/img/collapse-5p-exons.png"/>

- **Flexible first/last exon differences**

Previous versions of `collapse` used stringent maximum differences (5bp) for both internal junctions and external junctions. As of v3.8.0, the maximum 5p and 3p differences have been increased and paramaters added to allow adjustments. Note: the maximum 5p difference only applies when `--do-not-collapse-extra-5exons` is set.

Latest v4.0.0 `collapse` maximum junction difference parameters:
```
  --max-fuzzy-junction            INT    Ignore mismatches or indels shorter than or equal to N. [5]
  --max-5p-diff                   INT    Maximum allowed 5' difference if on same exon. [50]
  --max-3p-diff                   INT    Maximum allowed 3' difference if on same exon. [100]
```

<img width="1000px" src="https://isoseq.how/img/collapse-max-junctions.png"/>

## Mapping Iso-Seq transcripts to Sweet Cherry genome assembly
~~The consensus transcripts were mapped to the Sweet Cherry genome assembly using minimap2-2.17 (r941) (`-ax splice -uf –secondary = no –C5 –O6,24 –B4`) (Li, 2018). SAM ﬁles were sorted and used to collapse redundant isoforms using Cupcake v9.1.13. Unmapped and poorly mapped isoforms were used as input to Cogent v6.0.04 to reconstruct the coding genome. The reconstructed contigs were used as a fake genome to process and collapse the unmapped and poorly mapped reads through the ToFU pipeline.[^1]~~

Using [TAMA](https://github.com/GenomeRIK/tama/wiki) to collapse and mere reads/transcripts and apply novel methods to define splice junctions (SJs) and transcript start and end sites
```bash
minimap2 -ax splice:hq -uf final_markers.chr.fasta Regina_bud_leaf_isoforms.fa > Regina_isoforms_aln.sam
samtools sort Regina_isoforms_aln.sam -o Regina_isoforms_aln_sorted.sam
```
### Step 2 - TAMA collapse
```bash
python tama_collapse -d merge_dup -x no_cap -m 0 -a 0 -z 0 -sj sj_priority -lde 30 -sjt 30
```

```bash
python tama_format_gff_to_bed12_cupcake.py ../Reg_Iso_bud/7.collapse/Regina_bud.gff Regina_bud.bed
python tama_format_gff_to_bed12_cupcake.py ../Reg_Iso_leaf/7.collapse/Regina_leaf.gff Regina_leaf.bed
```
[^1]: Ali, A., Thorgaard, G. H., & Salem, M. (2021). PacBio Iso-Seq Improves the Rainbow Trout Genome Annotation and Identifies Alternative Splicing Associated With Economically Important Phenotypes. Frontiers in Genetics, 12, 683408. https://doi.org/10.3389/FGENE.2021.683408/BIBTEX
