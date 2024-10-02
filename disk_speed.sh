#!/bin/bash

# Check if the path is provided as input
if [ -z "$1" ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

# Define variables
TEST_PATH="$1"
DATE=$(date +%d-%b-%Y)
RESULTS_DIR="io-test-results-$DATE"
OUTPUT_FILE="$RESULTS_DIR/res.txt"

# Create directory for results if it doesn't exist
mkdir -p "$RESULTS_DIR"

# Define block sizes and counts to test
declare -A BLOCK_SIZES
BLOCK_SIZES["1M"]=10000
BLOCK_SIZES["50M"]=50
BLOCK_SIZES["1G"]=1
BLOCK_SIZES["1G"]=10

# Function to run dd tests and save output
run_dd_test() {
    local block_size=$1
    local count=$2
    local flag=$3
    local label=$4

    # Run the dd test and save the result
    result=$(dd if=/dev/zero of="$TEST_PATH/testfile" bs="$block_size" count="$count" oflag="$flag" 2>&1)
    # Extract speed information from the output
    speed=$(echo "$result" | grep -oP '\d+\.\d+ MB/s')

    # Append to output file and return speed
    echo "Block Size: $block_size, Count: $count, Flag: $flag ($label) => Speed: $speed" | tee -a "$OUTPUT_FILE"
    echo $speed
}

# Header for results
echo "Running dd tests on path: $TEST_PATH" | tee -a "$OUTPUT_FILE"
echo "Date: $DATE" | tee -a "$OUTPUT_FILE"
echo "======================" | tee -a "$OUTPUT_FILE"

# Run tests with 'dsync' and 'direct' flags
declare -A results_dsync
declare -A results_direct

for block in "${!BLOCK_SIZES[@]}"; do
    count=${BLOCK_SIZES[$block]}

    # Test with dsync
    results_dsync["$block"]=$(run_dd_test "$block" "$count" "dsync" "Data Sync")
    
    # Test with direct
    results_direct["$block"]=$(run_dd_test "$block" "$count" "direct" "Direct I/O")
done

# Display results in table format
echo -e "\nSummary of Test Results" | tee -a "$OUTPUT_FILE"
echo "=======================" | tee -a "$OUTPUT_FILE"
printf "%-12s | %-10s | %-10s\n" "Block Size" "dsync (MB/s)" "direct (MB/s)" | tee -a "$OUTPUT_FILE"
echo "------------------------------" | tee -a "$OUTPUT_FILE"

for block in "${!BLOCK_SIZES[@]}"; do
    printf "%-12s | %-10s | %-10s\n" "$block" "${results_dsync[$block]}" "${results_direct[$block]}" | tee -a "$OUTPUT_FILE"
done

# Cleanup test file
rm -f "$TEST_PATH/testfile"
