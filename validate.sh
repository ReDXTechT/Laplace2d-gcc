#!/bin/bash

# Check if all required arguments are present
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 makefile_directory expected_output tolerance min_time max_time"
    exit 1
fi

# Assign input parameters to variables
MAKEFILE_DIR=$1
EXPECTED_OUTPUT_FILE=$2
TOLERANCE=$3
MIN_TIME=$4
MAX_TIME=$5

# Name of the executable
EXE="$MAKEFILE_DIR/exe"

# Navigate to the makefile directory and clean up any existing compiled files
cd "$MAKEFILE_DIR" && make clean

# Execute the makefile
make all

# Return to the original directory
cd - > /dev/null

# Redirect output of the executable to a file
"$EXE" > output.txt


# Flags to mark if output is as expected and execution time is within range
is_output_expected=true
is_exec_time_within_range=true

# Read expected values from file
declare -A expected_values
while read -r iteration expected_value; do
    expected_values[$iteration]=$expected_value
done < $EXPECTED_OUTPUT_FILE

# Iterate through each line of the output
while read -r line; do
    # Check if line contains total time
    if [[ $line == *"total"* ]]; then
        exec_time=$(echo "$line" | awk '{print $2}')
        if (( $(echo "$exec_time < $MIN_TIME" | bc -l) )) || (( $(echo "$exec_time > $MAX_TIME" | bc -l) )); then
            is_exec_time_within_range=false
            echo "Execution time ($exec_time s) is not within the expected range ($MIN_TIME - $MAX_TIME s)."
        fi
        continue
    fi

    # Get the iteration and value
    iteration=$(echo "$line" | awk '{print $1}' | tr -d ',')
    value=$(echo "$line" | awk '{print $2}')

    # Compare with expected value, if an expected value is defined
    if [ "${expected_values[$iteration]}" != "" ]; then
        difference=$(echo "${expected_values[$iteration]} - $value" | bc -l | tr -d -)

        if (( $(echo "$difference > $TOLERANCE" | bc -l) )); then
            is_output_expected=false
            echo "the Value given by the compiler at iteration $iteration is $value, but value given by competitor ${expected_values[$iteration]}. , the difference : $difference "
        fi
    fi
done < output.txt

if $is_output_expected; then
    echo "All output values are within the tolerance."
else
    echo "Some output values are not within the tolerance."
fi

if $is_exec_time_within_range; then
    echo "Execution time is within the expected range."
else
    echo "Execution time is not within the expected range."
fi

# Clean up the output file
rm output.txt

