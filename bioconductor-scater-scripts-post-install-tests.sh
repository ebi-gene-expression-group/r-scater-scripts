#!/usr/bin/env bash

script_dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
script_name=$0

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: r-seurat-workflow-post-install-tests.sh [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_data_url='https://s3-us-west-2.amazonaws.com/10x.files/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz'
test_working_dir=`pwd`/'post_install_tests'
export test_data_archive=$test_working_dir/`basename $test_data_url`

# Clean up if specified

if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi 

# Initialise directories

output_dir=$test_working_dir/outputs
export data_dir=$test_working_dir/test_data

mkdir -p $test_working_dir
mkdir -p $output_dir
mkdir -p $data_dir

################################################################################
# Fetch test data 
################################################################################

if [ ! -e "$test_data_archive" ]; then
    wget $test_data_url -P $test_working_dir
    
fi
    
################################################################################
# List tool outputs/ inputs
################################################################################

export raw_matrix=$data_dir'/matrix.mtx'
export raw_singlecellexperiment_object="$output_dir/raw_sce.rds"
export cpm_singlecellexperiment_object="$output_dir/cpm_sce.rds"
export norm_singlecellexperiment_object="$output_dir/norm_sce.rds"
export pca_singlecellexperiment_object="$output_dir/pca_sce.rds"
export pca_plot_file="$output_dir/pca.png"
export tsne_plot_file="$output_dir/tsne.png"
export tsne_singlecellexperiment_object="$output_dir/tnse_sce.rds"
export qc_singlecellexperiment_object="$output_dir/qc_sce.rds"
export filtered_singlecellexperiment_object="$output_dir/filtered_sce.rds"
export cell_filter_matrix="$output_dir/filtered_cells.csv"
export feature_filter_matrix="$output_dir/filtered_features.csv"
export cpm_matrix=$output_dir'/cpm_matrix.mtx'
export spikein_gene_sets_file="$output_dir/random_genes.txt"
export extracted_metrics_file="$output_dir/total_counts.txt"
export outliers_file="$output_dir/outliers.txt"

## Test parameters- would form config file in real workflow. DO NOT use these
## as default values without being sure what they mean.

### Workflow parameters

export col_names=TRUE
export cell_metrics=total_counts,total_features_by_counts
export gene_metrics=n_cells_by_counts
export min_cell_total_counts=500
export min_cell_total_features=50
export min_feature_n_cells_counts=10
export size_factors='TRUE'
export exprs_values="counts"
export return_log='TRUE'
export log_exprs_offset=1
export centre_size_factors='TRUE'
export cell_controls='NULL'
export percent_top='5,100,200,500'
export detection_limit=5
export use_spikes=TRUE
export n_spikein_genes=10
export n_spikein_gene_sets=2
export outlier_min_diff=5
export nmads=5
export outlier_type='higher'
export outlier_log='TRUE'
export outlier_test_metric='total_counts'
export pca_ncomponents=2
export pca_method='prcomp'
export pca_ntop=500
export pca_exprs_values='logcounts'
export pca_scale_features=TRUE
export pca_detect_outliers=TRUE
export tsne_use_dimred='PCA'
export tsne_n_dimred=20
export tsne_perplexity=25

export plot_components='1,2'
export png_height=1000
export png_width=1000

################################################################################
# Test individual scripts
################################################################################

# Make the script options available to the tests so we can skip tests e.g.
# where one of a chain has completed successfullly.

export use_existing_outputs

# Derive the tests file name from the script name

tests_file="${script_name%.*}".bats

# Execute the bats tests

$tests_file
