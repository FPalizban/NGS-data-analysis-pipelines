version 1.0


workflow CNV_calling {
  call conifer
}
task conifer {
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
    File conifer
    File probes
    String rpkm_dir
    
	
  }
  command {
     bwa mem -M -K 100000000 ${ref_fasta} ${inputfastq1} ${inputfastq2} > ${sampleName}.sam && samtools view -S -b ${sampleName}.sam > ${sampleName}.bam && java -jar ${picard} AddOrReplaceReadGroups I= ${sampleName}.bam O= ${sampleName}_RG.bam RGID=4 RGLB=twist RGPL=illumina RGPU=unit1 RGSM=${sampleName} && java -jar ${picard} SortSam I= ${sampleName}_RG.bam O=${sampleName}_RG_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_RG_sorted.bam && python3 ${conifer} rpkm --probes ${probes} --input ${sampleName}_RG_sorted.bam  --output ${rpkm_dir}/${sampleName}.rpkm.txt && python3 ${conifer} analyze --probes ${probes} --rpkm_dir ${rpkm_dir} --output ${sampleName}_analysis.hdf5 --svd 6 --write_svals ${sampleName}_singular_values.txt --plot_scree ${sampleName}_screeplot.png --write_sd ${sampleName}_sd_values.txt && python3 ${conifer} call --input ${sampleName}_analysis.hdf5 --output ${sampleName}_calls.txt && python3 ${conifer} export --input ${sampleName}_analysis.hdf5 --sample ${sampleName} --output ./export_svdzrpkm/${sampleName}.svdzrpkm.bed 
   }
  output {
    File bam = "${sampleName}_RG_sorted.bam"
    File hdf5 = "${sampleName}_analysis.hdf5"
    File bed = "${sampleName}.svdzrpkm.bed "
  }
}


