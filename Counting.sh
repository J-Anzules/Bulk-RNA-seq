#!/bin/bash

# move to where the data will  handled
cd /mnt/c/Users/jonan/Documents/Tyseq/Data

# Prompt user for the name of the folder with data that needs to be aligned
echo "Enter the name of the folder containing the files to be aligned:"
read input_folder
# trimmed_fastq_2_aligned
echo "Name the output folder"
read output_folder

# Making the outputfolder
mkdir "$output_folder"

for file in "${input_folder}"/*.sam 
    do
    echo "Old filename: $file"

    # Creating all the variable names for this process
    # Extract the filename without extension
    filename=$(basename "$file" .sam)
    # Remove the "_trimmed_alignment" suffix from the filename
    filename=${filename/_trimmed_alignment/}    
    # Construct the new filename with .bam extension
    new_file="${output_folder}/${filename}.bam"
    # Making the sorted file name
    sorted_file="${new_file%.bam}_sorted.bam"
    counts_file="${sorted_file%_sorted.bam}.tsv"


    echo "New filename: $new_file"
    echo "Sorted filename: $sorted_file"
    echo "counts filename: $counts_file"
    
    # processing using samtools

    echo "Processing file: ${filename}...."
    samtools view -bS "$file" > "$new_file"
    echo "Soring file: ${filename}...."
    samtools sort -o "$sorted_file" "$new_file"
    echo "indexing file: ${filename}...."
    samtools index "$sorted_file"
    # remove the new_file once sorted is created
    rm "$new_file"

    # featureCounts
    echo "Making the counts file: ${filename}...."
    featureCounts   -a hg19/GRCh37_gencodesgenes_hg19/gencode.v19.chr_patch_hapl_scaff.annotation.gtf \
                    -o "$counts_file" \
                    "$sorted_file"


done

# Moving all bam files
mkdir "$output_folder/bam_files"
mv *.bam "$output_folder/bam_files"
