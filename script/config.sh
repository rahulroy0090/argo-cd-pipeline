#!/bin/bash

echo $1 " :::::::::  "$2;

# Define input and output files
#input_file="old-configmap.yaml"
input_file=$3
output_file="$2/templates/configmap.yaml"

# Helm template variables
namespace="{{ .Values.namespace }}"
config_map_name="{{ .Values.configMap.name }}"

# Write initial lines to output file
cat > "$output_file" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $config_map_name
  namespace: $namespace
  labels:
    app: $config_map_name
data:
EOF

# Read and process the input file line by line
while IFS=":" read -r key value; do
  # Skip comments and empty lines
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Trim leading/trailing whitespace
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)

  # Generate cleaned key for Helm templating (remove . and -)
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

  # Write to output
  echo "  $key: {{ .Values.configMap.data.$cleaned_key | quote }}" >> "$output_file"
done < "$input_file"

echo "Conversion completed! New ConfigMap written to $output_file"

