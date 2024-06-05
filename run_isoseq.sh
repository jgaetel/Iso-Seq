#!/bin/bash

RAW_DIR='1.rawdata'
CCS_DIR='2.ccs'
PRIM_DIR='3.primer_removal'
REF_DIR='4.refine'
CLUS_DIR='5.clustering'
CCS="/home/jgaete/.conda/envs/pacbiotools/bin/ccs"
ISOSEQ='/home/jgaete/.conda/envs/isoseq/bin'
THREADS=104
PRIMERS='/home/compartida_sakuromics/Iso-seq/IsoSeqPrimers.fasta'

echo "### Step 0: Check output directories' existence & create them as needed"
[ -d $CCS_DIR ] || mkdir -p $CCS_DIR
[ -d $PRIM_DIR ] || mkdir -p $PRIM_DIR
[ -d $REF_DIR ] || mkdir -p $REF_DIR
[ -d $CLUS_DIR ] || mkdir -p $CLUS_DIR

for BAM in 1.rawdata/*bam; do
        SUBREADS=$(basename $BAM)
        PREFIX=${SUBREADS%%.*}
        echo "### 1. Reading ${BAM} subreads"
        echo "### 2. Compute CCS"
        $CCS --min-rq 0.9 -j $THREADS $RAW_DIR/$SUBREADS $CCS_DIR/${PREFIX}.ccs.bam
        echo "### 3. Primers removal"
        $ISOSEQ/lima -j $THREADS $CCS_DIR/${PREFIX}.ccs.bam $PRIMERS $PRIM_DIR/${PREFIX}.bam --isoseq
        echo "### 4. Concatemer removal"
        $ISOSEQ/isoseq refine -j $THREADS $PRIM_DIR/${PREFIX}.primer_5p--primer_3p.bam $PRIMERS $REF_DIR/${PREFIX}.flnc.bam
done;

cd $REF_DIR
\ls *.flnc.bam > flnc.fofn
cd ..

echo "### 5. Clustering"
$ISOSEQ/isoseq cluster2 $REF_DIR/flnc.fofn $CLUS_DIR/Regina_leaf_clustered.bam
