# Iso-Seq assembly and functional annotation of full-length transcriptome of Sweet Cherry during dormancy

Firstly, Iso-Seq reads were submitted to three successive steps: establishing of circular consensus sequences (CCS), demultiplexing according to the Leishmania species and reﬁnement by using the command line IsoSeq v3 (v3.4.0), implemented in the IsoSeq GUI-based analysis application (SMRT Link v6.0.0). In order to generate one representative CCS for each transcript the zero-mode waveguide (ZMW) of the CCS (v6.4.0) program was used with the `--min-rq 0.9` parameter. Barcode demultiplexing and primer removal were performed using lima (version v1.10.0) with the `--isoseq` mode and `--peek-guess` parameter to remove spurious false positive signal. IsoSeq3 reﬁne (option `--require-polya`) was used to select those reads having a 3’-end adenine (A)-tract, after trimming out the poly(A) tails and concatemer identiﬁcation the FLNC transcripts were generated.

<img width="780px" src="https://github.com/PacificBiosciences/IsoSeq/blob/master/doc/img/isoseq-clustering-end-to-end.png"/>

The working directory has the following structure:

```
Reg
└── Reg_Iso_bud
    ├── 1.rawdata
    ├── 2.ccs
    ├── 3.primer_removal
    ├── 4.refine
    ├── 5.clustering
    ├── 6.mapping
    └── 7.collapse
```
