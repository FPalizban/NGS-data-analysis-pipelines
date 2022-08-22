version 1.0


workflow RNA_Seq {
  call hisat2
}
task hisat2 {
  input {
    File inputfastq1
    File inputfastq2
    String sampleName
    String hisat_index
    File ref_gtf
    File picard
  }
  command {
     hisat2 -p 8 -x ${hisat_index} -1 ${inputfastq1} -2 ${inputfastq2} -S ${sampleName}.sam && samtools view -S -b ${sampleName}.sam > ${sampleName}.bam  && java -jar ${picard} SortSam I= ${sampleName}.bam O=${sampleName}_sorted.bam SORT_ORDER=coordinate &&  java -jar ${picard} BuildBamIndex I= ${sampleName}_sorted.bam && stringtie -A -e -G ${ref_gtf} -o ${sampleName}.out.gtf ${sampleName}_sorted.bam
   }
  output {
    File sorted_bam = "${sampleName}_sorted.bam"
    File gtf = "${sampleName}.out.gtf"
  }
}


