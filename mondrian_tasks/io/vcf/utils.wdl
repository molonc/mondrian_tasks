version 1.0


task VcfReheaderId{
    input{
        File input_vcf
        File normal_bam
        File tumour_bam
        String vcf_tumour_id
        String vcf_normal_id
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8
    }
    command<<<
        variant_utils vcf_reheader_id \
        --input ~{input_vcf} \
        --tumour ~{tumour_bam} \
        --normal ~{normal_bam} \
        --output output.vcf.gz \
        --vcf_tumour_id ~{vcf_tumour_id} \
        --vcf_normal_id ~{vcf_normal_id}
    >>>
    output{
        File output_file = "output.vcf.gz"
    }
    runtime{
        memory: "~{memory_gb} GB"
        cpu: 1
        walltime: "~{walltime_hours}:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}