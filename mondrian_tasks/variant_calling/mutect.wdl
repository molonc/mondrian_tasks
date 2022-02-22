version 1.0

task GetSampleId{
    input{
        File input_bam
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<

    variant_utils get_sample_id_bam --input ~{input_bam} > sampleid.txt
    >>>
    output{
        String sample_id = read_string("sampleid.txt")
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}



task RunMutect{
    input{
        File normal_bam
        File normal_bai
        File tumour_bam
        File tumour_bai
        File reference
        File reference_fai
        File reference_dict
        Array[String] intervals
        Int cores
        String normal_sample_id
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
        mkdir raw_data
        mkdir filtered_data
        for interval in ~{sep=" "intervals}
            do
                echo "gatk Mutect2 --input ~{normal_bam} --input ~{tumour_bam} --normal ~{normal_sample_id} \
                -R ~{reference} -O raw_data/${interval}.vcf  --intervals ${interval} ">> commands.txt
            done
        parallel --jobs ~{cores} < commands.txt
        for interval in ~{sep=" "intervals}
            do
                echo "gatk FilterMutectCalls -R ~{reference} -V raw_data/${interval}.vcf -O filtered_data/${interval}.vcf " >> filter_commands.txt
            done
        parallel --jobs ~{cores} < filter_commands.txt
    >>>
    output{
        Array[File] vcf_files = glob("filtered_data/*.vcf")
    }
    runtime{
        memory: "12 GB"
        cpu: "~{cores}"
        walltime: "8:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

task FilterMutect{
    input{
        File reference
        File reference_fai
        File reference_dict
        File vcf_file
        String? singularity_image
        String? docker_image
        Int? memory_gb = 12
        Int? walltime_hours = 8

    }
    command<<<
            gatk FilterMutectCalls -R ~{reference} -V ~{vcf_file} -O filtered.vcf
    >>>
    output{
        File filtered_vcf = "filtered.vcf"
    }
    runtime{
        memory: "12 GB"
        cpu: 1
        walltime: "8:00"
        docker: '~{docker_image}'
        singularity: '~{singularity_image}'
    }
}

