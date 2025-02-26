## Human bulk RNA-seq data processing pipeline
This pipeline utilizes [nf-core RNA-seq v.3.12.0](https://nf-co.re/rnaseq/3.12.0) STAR-Salmon mode which performs read alignment and transcript quantification of bulk RNA-seq data with the Nextflow workflow manager. The nf-core is a bioinformatics community project for making computational methods portable and reproducible. 
To demonstrate this pipeline, a bulk mRNA-seq dataset with biological replicates and technical replicates from a public dataset, [GSE82236](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE82236) is used. Human genome reference version GRCh38 primary assembly and annotation version [Gencode v44 Basic](https://www.ensembl.org/info/genome/genebuild/transcript_quality_tags.html#basic) are used. 

*Input files for nf-core RNA-seq workflow*
- example_DesignFile.csv: Sample names, (relative or absolute) paths to data files, and NGS library strandedness according to the nf-core guideline.
- example_nf-params.json: Pre-defined nf-core parameters. It includes paths to the reference genome (.fasta) and annotation (.gtf) files.
- example_run_nextflow.sh: Bash script file to initiate a Nextflow run (a.k.a your magic button). You can adjust the ‘wdir’, ‘proj’ and ‘run’ parameters before initiating the run.
Organize your project as [working_directory]/[project_title]/[run_name]/ so you can save the results from multiple runs under a single project folder. Now this is where your “work” and “result” folders will be created from the run.

*Before running the pipeline* 
- Check your raw data size & estimate your project folder size: $ du -hsc /path/to/raw/.fastq.gz
- Check storage space in the server: $ df -H /home/path/
- Coordinate with other users for optimal memory usage: $ htop

*Output files* 
- Quality control (.html): /result/multiqc/star_salmon/multiqc_report.html
- Alignment files (.markdup.sorted.bam): /result/star_salmon/[sample_name].markdup.sorted.bam
- Count files merged for all samples (.tsv): /result/star_salmon/salmon.merged.gene_counts.tsv
- Count files per sample (.sf): /result/star_salmon/[sample_name]/quant.genes.sf

*BAM file validation*  
We found truncated BAM files even with a successful completion message from the Nextflow run. This is because the server storage got full at the time of writing the files. Such error is not detectable by the original pipeline, hence additional checks on all BAM files are now added in example_run_nextflow.sh. The following files can be found in /result/star_salmon/picard_validatesamfile. 
- bad_bams.fofn: quick check whether the BAM files have EOF (end-of-file) marks.
- bam_summary.txt: full output of Picard ValidateSamFile
- error_messages.txt: file name and detected error and warning messages extracted from bam_summary.txt. Please check the [GATK troubleshooting page](https://gatk.broadinstitute.org/hc/en-us/articles/360035891231-Errors-in-SAM-or-BAM-files-can-be-diagnosed-with-ValidateSamFile) for what they mean.

*After running the pipeline* 
- Please check the execution report, multiqc report, and bam file validation result to assess the successful completion of all the stages.
- Please remove scratch/ and work/ directories from the server.

*Set up for DEA (Differential Expression Analysis)*  
The R Markdown document (.RMD) file reads in the output files of the nf-core RNA-seq workflow and detects differentially expressed genes using DESeq2 package. It is assumed that this file is in the same [working_directory]. Any figures and gene lists from the analysis would be saved under [working_directory]/[project_title]/[run_name]/DEAoutput. 

*File tree*  
```{bash}
├── [working_directory]/ 
│…. ├── example_DesignFile.csv 
│…. ├── example_nf-params.json 
│…. ├── example_run_nextflow.sh 
│…. ├── CBBI_RNAseq_manual.rmd 
│…. ├── [project_title]/ 
│…. │…. ├── [run_name]/ 
│…. │…. │…. ├── result/ 
│…. │…. │…. │…. ├── pipeline_info/ 
│…. │…. │…. │…. │…. ├── execution_report_yyyy-mm-dd_hh-mm-ss.html 
│…. │…. │…. │…. ├── multiqc/ 
│…. │…. │…. │…. │…. ├── star_salmon/ 
│…. │…. │…. │…. │…. │…. ├── multiqc_report.html 
│…. │…. │…. │…. ├── star_salmon/ 
│…. │…. │…. │…. │…. ├── [sample_name].markdup.sorted.bam 
│…. │…. │…. │…. │…. ├── [sample_name].Aligned.out.bam 
│…. │…. │…. │…. │…. ├── salmon.merged.gene_counts.tsv 
│…. │…. │…. │…. │…. ├── salmon.merged.gene_tpm.tsv 
│…. │…. │…. │…. │…. ├── [sample_name]/ 
│…. │…. │…. │…. │…. │…. ├── quant.genes.sf 
│…. │…. │…. │…. │…. │…. ├── quant.sf 
│…. │…. │…. │…. │…. ├── picard_validatesamfile/ 
│…. │…. │…. │…. │…. │…. ├── error_messages.txt 
│…. │…. │…. ├── work/ 
│…. │…. │…. ├── scratch/ 
│…. │…. │…. ├── DEAoutput/ 
│…. │…. │…. │…. ├── DEA_all_genes.csv 
```
