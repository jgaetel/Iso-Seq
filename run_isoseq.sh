#!/bin/bash
#SBATCH --job-name=RbudIsoseq
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

RAW_DIR='1.rawdata'
CCS_DIR='2.ccs'
PRIM_DIR='3.primer_removal'
REF_DIR='4.refine'
CLUS_DIR='5.clustering'
MAP_DIR='6.mapping'
COL_DIR='7.collapse'
TAMA_DIR='7.tama_collapse'
PRIMERS='/home/compartida_sakuromics/Iso-seq/IsoSeqPrimers.fasta'

echo "### Step 0: Check output directories' existence & create them as needed"
[ -d $CCS_DIR ] || mkdir -p $CCS_DIR
[ -d $PRIM_DIR ] || mkdir -p $PRIM_DIR
[ -d $REF_DIR ] || mkdir -p $REF_DIR
[ -d $CLUS_DIR ] || mkdir -p $CLUS_DIR
#[ -d $MAP_DIR ] || mkdir -p $MAP_DIR
#[ -d $COL_DIR ] || mkdir -p $COL_DIR

module load pacbiotools
for BAM in 1.rawdata/*bam; do
        SUBREADS=$(basename $BAM)
        PREFIX=${SUBREADS%%.*}
        echo "--------------------------------------------------"
        echo "### 1. Reading ${BAM} subreads"
        echo "### 2. Compute CCS"
        ccs -j $SLURM_CPUS_PER_TASK $RAW_DIR/$SUBREADS $CCS_DIR/${PREFIX}.ccs.bam
        echo "### 3. Primers removal"
        lima -j $SLURM_CPUS_PER_TASK $CCS_DIR/${PREFIX}.ccs.bam $PRIMERS $PRIM_DIR/${PREFIX}.bam --isoseq --peek-guess
        echo "### 4. Concatemer removal"
        isoseq refine -j $SLURM_CPUS_PER_TASK --require-polya $PRIM_DIR/${PREFIX}.primer_5p--primer_3p.bam $PRIMERS $REF_DIR/${PREFIX}.flnc.bam
done;

#cd $REF_DIR
#\ls *.flnc.bam > flnc.fofn
#cd ..

echo "### 5. Clustering"
isoseq cluster2 -j $SLURM_CPUS_PER_TASK $REF_DIR/${PREFIX}.flnc.bam $CLUS_DIR/Regina_bud_clustered.bam
