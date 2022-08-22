version 1.0


workflow germline_calling {
  call HaplotypeCaller
}
task HaplotypeCaller {
  input {
    File inputfastq1
    File inputfastq2
    String sampleName
    File ref_fasta
    File ref_fasta_index
    File ref_dict
    File? ref_alt
    File ref_amb
    File ref_ann
    File ref_bwt
    File ref_pac
    File ref_sa
    File picard
    File gatk
  }
  command {
     bwa mem -M -K 100000000 ${ref_fasta} ${inputfastq1} ${inputfastq2} > ${sampleName}.sam && samtools view -S -b ${sampleName}.sam > ${sampleName}.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}.bam O= ${sampleName}_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_RG.bam O=${sampleName}_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_RG_sorted.bam && java -jar ${picard} MarkDuplicates I= ${sampleName}_RG_sorted.bam O= ${sampleName}_dedup.bam M=${sampleName}_dup_metrics.txt && java -jar ${picard} BuildBamIndex I= ${sampleName}_dedup.bam && java  -jar ${gatk} HaplotypeCaller -R ${ref_fasta} -I ${sampleName}_dedup.bam -O ${sampleName}.vcf.gz
   }
  output {
    File dedup_bam = "${sampleName}_dedup.bam"
    File VCF = "${sampleName}.vcf.gz"
  }
}


