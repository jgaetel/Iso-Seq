# Iso-Seq

Firstly, Iso-Seq reads were submitted to three successive steps: establishing of circular consensus sequences (CCS), demultiplexing according to the Leishmania species and reﬁnement by using the command line IsoSeq v3 (v3.4.0), implemented in the IsoSeq GUI-based analysis application (SMRT Link v6.0.0). In order to generate one representative CCS for each transcript the zero-mode waveguide (ZMW) of the CCS (v6.4.0) program was used with the - -min-rq 0.9, –draft-mode winpoa and –disable-heuristics parameters. Barcode demultiplexing and primer removal were performed using lima (version v1.10.0) with the –isoseq mode and –peek-guess parameter to remove spurious false positive signal. IsoSeq3 reﬁne (option –require-poly-A) was used to select those reads having a 3’-end adenine (A)-tract, after trimming out the poly(A) tails and concatemer identiﬁcation the FLNC transcripts were generated.

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
## Circular consensus sequences
Polished CCS subreads were generated, using CCS v.6.4.0, from the subreads bam files witha minimum quality of 0.9.
```bash
ccs --min-rq 0.9 -j 104 1.rawdata/m64083_230912_092706.subreads.bam 2.ccs0.9/m64083_230912_092706.ccs.bam
```

## 
```bash
lima -isoseq -peek-guess
```

The consensus transcripts were mapped to the Swanson rainbow trout reference genome (Pearse et al., 2020) using minimap2-2.17 (r941) (-ax splice -uf –secondary = no –C5 –O6,24 –B4) (Li, 2018). SAM ﬁles were sorted and used to collapse redundant isoforms using Cupcake v9.1.13. Unmapped and poorly mapped isoforms were used as input to Cogent v6.0.04 to reconstruct the coding genome. The reconstructed contigs were used as a fake genome to process and collapse the unmapped and poorly mapped reads through the ToFU pipeline.[^1]

[^1]Ali, A., Thorgaard, G. H., & Salem, M. (2021). PacBio Iso-Seq Improves the Rainbow Trout Genome Annotation and Identifies Alternative Splicing Associated With Economically Important Phenotypes. Frontiers in Genetics, 12, 683408. https://doi.org/10.3389/FGENE.2021.683408/BIBTEX
