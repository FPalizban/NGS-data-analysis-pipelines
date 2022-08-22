version 1.0


workflow trio_calling {
  call varscan
}
task varscan {
  input {
    File mom_inputfastq1
    File mom_inputfastq2
    File dad_inputfastq1
    File dad_inputfastq2
    File child_inputfastq1
    File child_inputfastq2
    String sampleName
    File ref_fasta
    File ref_fasta_index
    File ref_dict
    File ref_amb
    File ref_ann
    File ref_bwt
    File ref_pac
    File ref_sa
    File picard
    File VarScan
  }
  command {
     bwa mem -M -K 100000000 ${ref_fasta} ${mom_inputfastq1} ${mom_inputfastq2} > ${sampleName}_mom.sam && samtools view -S -b ${sampleName}_mom.sam > ${sampleName}_mom.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}_mom.bam O= ${sampleName}_mom_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_mom_RG.bam O=${sampleName}_mom_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_mom_RG_sorted.bam && bwa mem -M -K 100000000 ${ref_fasta} ${dad_inputfastq1} ${dad_inputfastq2} > ${sampleName}_dad.sam && samtools view -S -b ${sampleName}_dad.sam > ${sampleName}_dad.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}_dad.bam O= ${sampleName}_dad_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_dad_RG.bam O=${sampleName}_dad_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_dad_RG_sorted.bam && bwa mem -M -K 100000000 ${ref_fasta} ${child_inputfastq1} ${child_inputfastq2} > ${sampleName}_child.sam && samtools view -S -b ${sampleName}_child.sam > ${sampleName}_child.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}_child.bam O= ${sampleName}_child_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_child_RG.bam O=${sampleName}_child_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_child_RG_sorted.bam && samtools mpileup -B -q 1 -f ref.fasta ${sampleName}_mom_RG_sorted.bam ${sampleName}_dad_RG_sorted.bam ${sampleName}_child_RG_sorted.bam > ${sampleName}_trio.mpileup && java -jar ${VarScan} trio ${sampleName}_trio.mpileup ${sampleName}_trio.mpileup.output --min-coverage 10 --min-var-freq 0.20 --p-value 0.05  -adj-var-freq 0.05 -adj-p-value 0.15

   }
  output {
    File child_bam = "${sampleName}_child_RG_sorted.bam"
    File mom_bam = "${sampleName}_mom_RG_sorted.bam"
    File dad_bam = "${sampleName}_dad_RG_sorted.bam"
    File trio_in = "${sampleName}_trio.mpileup"
    File trio_out = "${sampleName}_trio.mpileup.output"
  }
}


