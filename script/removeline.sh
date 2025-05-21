#!/bin/bash

echo $1 " :::::::::  "$2;

# Define input and output files
input_file="old-configmap.yaml"
output_file="$2/values.yaml"


# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
  echo "Input file '$input_file' not found!"
  exit 1
fi

# Check if the output file exists and contains a 'data:' section
if [[ -f "$output_file" ]]; then
  data_found=false
  # Loop through the output file to check for the 'data:' section
  while IFS= read -r line; do
    if [[ "$line" == "data:" ]]; then
      data_found=true
      break
    fi
  done < "$output_file"
fi

# If the 'data:' section exists, append new data below it, else start fresh with 'data:'
if [[ "$data_found" == true ]]; then
  # Read input line by line
  while IFS= read -r line; do
    # Check if line contains a colon
    if [[ "$line" == *:* ]]; then
      # Extract the key and value
      key="${line%%:*}"
      value="${line#*:}"

      # Remove dots and dashes from the key
      ##cleaned_key="${key//./}"
      ##cleaned_key="${cleaned_key//-/}"
      
      # Split by dot or underscore or dash, capitalize each part (except the first), and concatenate
      cleaned_key=$(echo "$key" | awk -F'[.-]' '{
          result = $1
          for (i = 2; i <= NF; i++) {
              part = $i
              part = toupper(substr(part, 1, 1)) substr(part, 2)
              result = result part
          }
          print result
      }')

      # Append the cleaned key-value pair under the 'data:' section
      echo "$cleaned_key:$value" >> "$output_file"
    else
      # Write the line as-is (e.g., blank lines or malformed lines)
      echo "$line" >> "$output_file"
    fi
  done < "$input_file"
else
  # Empty the output file before writing
  > "$output_file"

  # Write the header and 'data:' section
  echo "namespace: esb-p2mpay-user-management-services" > "$output_file"
  echo "replicaCount: 1" >> "$output_file"
  echo "" >> "$output_file"
  echo "image:" >> "$output_file"
  echo "  repository: registry.preprod.finopaymentbank.in/p2mpay/cashinpostingcbsmta" >> "$output_file"
  echo "  tag: \"1234567890\"" >> "$output_file"
  echo "  pullPolicy: IfNotPresent" >> "$output_file"
  echo "" >> "$output_file"
  echo "imagePullSecrets:" >> "$output_file"
  echo "  - name: regsecret" >> "$output_file"
  echo "" >> "$output_file"
  echo "serviceAccountName: default" >> "$output_file"
  echo "configMapName: cashinpostingcbsmta" >> "$output_file"
  echo "containerPort: 8080" >> "$output_file"
  echo "" >> "$output_file"
  echo "annotations:" >> "$output_file"
  echo "  sidecar.istio.io/inject: \"true\"" >> "$output_file"
  echo "  sidecar.jaegertracing.io/inject: \"true\"" >> "$output_file"
  echo "" >> "$output_file"
  #echo "nodeSelector:" >> "$output_file"
  #echo "  app: mta" >> "$output_file"
  #echo "" >> "$output_file"
  echo "resources: {}" >> "$output_file"
  echo "" >> "$output_file"
  echo "serviceAccount:" >> "$output_file"
  echo "  create: true" >> "$output_file"
  echo "  name: cashinpostingcbsmta" >> "$output_file"
  echo "" >> "$output_file"
  echo "service:" >> "$output_file"
  echo "  name: cashinpostingcbsmta" >> "$output_file"
  echo "  port: 8080" >> "$output_file"
  echo "  targetPort: 8080" >> "$output_file"
  echo "  protocol: TCP" >> "$output_file"
  echo "  type: ClusterIP" >> "$output_file"
  echo "  selector:" >> "$output_file"
  echo "    app: cashinpostingcbsmta" >> "$output_file"
  echo "" >> "$output_file"
  echo "configMap:" >> "$output_file"
  echo "  name: cashinpostingcbsmta" >> "$output_file"
  echo "  data:" >> "$output_file"
  
  # Now append new data under the 'data:' section
  while IFS= read -r line; do
    if [[ "$line" == *:* ]]; then
      # Extract the key and value
      key="${line%%:*}"
      value="${line#*:}"

      # Remove dots and dashes from the key
      ##cleaned_key="${key//./}"
      ##cleaned_key="${cleaned_key//-/}"

      # Split by dot or underscore or dash, capitalize each part (except the first), and concatenate
      cleaned_key=$(echo "$key" | awk -F'[.-]' '{
          result = $1
          for (i = 2; i <= NF; i++) {
              part = $i
              part = toupper(substr(part, 1, 1)) substr(part, 2)
              result = result part
          }
          print result
      }')

      # Append the cleaned key-value pair under 'data:'
      echo "    $cleaned_key: $value" >> "$output_file"
    fi
  done < "$input_file"
fi

echo "Processed output written to '$output_file'"

