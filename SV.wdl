version 1.0


workflow SV_calling {
  call manta
}
task manta {
  input {
    File inputfastq1
    File inputfastq2
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
    File manta
    String manta_dir
	
  }
  command {
     bwa mem -M -K 100000000 ${ref_fasta} ${inputfastq1} ${inputfastq2} > ${sampleName}.sam && samtools view -S -b ${sampleName}.sam > ${sampleName}.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}.bam O= ${sampleName}_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_RG.bam O=${sampleName}_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_RG_sorted.bam && ./${manta} --bam ${sampleName}_RG_sorted.bam --referenceFasta ${ref_fasta} --runDir ${manta_dir}  
   }
  output {
    File bam = "${sampleName}_RG_sorted.bam"
    File VCF = "${manta_dir}/*.vcf.gz"
  }
}


