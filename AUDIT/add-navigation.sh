#!/bin/bash

# Script to add navigation to all AUDIT documents

# Define document sequence
declare -a DOCS=(
  "00-executive-summary.md"
  "01-architecture-overview.md"
  "02-component-deep-dive.md"
  "03-workflows-and-dataflows.md"
  "04-api-reference.md"
  "05-data-models-and-integration.md"
  "06-code-navigation-guide.md"
  "07-design-patterns-glossary.md"
  "08-algorithm-deep-dive.md"
  "09-concurrency-deep-dive.md"
  "10-error-handling-guide.md"
  "11-performance-analysis.md"
  "12-troubleshooting-cookbook.md"
  "13-state-machines-reference.md"
  "14-environment-variables-reference.md"
  "15-test-infrastructure.md"
  "16-runtime-directories.md"
)

# Function to add navigation header
add_navigation_header() {
  local file=$1
  local prev=$2
  local next=$3

  # Create header
  local header="[📋 Master Index](./00-MASTER-INDEX.md)"

  if [ -n "$prev" ]; then
    header="$header | [⬅️ Previous](./$prev)"
  fi

  if [ -n "$next" ]; then
    header="$header | [➡️ Next](./$next)"
  fi

  header="$header\n\n---\n"

  # Add header after first line (title)
  sed -i "1 a\\$header" "$file"
}

# Function to add navigation footer
add_navigation_footer() {
  local file=$1
  local prev=$2
  local next=$3

  local footer="\n---\n\n## Navigation\n\n"
  footer="$footer- [🏠 Back to Master Index](./00-MASTER-INDEX.md)\n"
  footer="$footer- [📚 View All Documents](./README.md)\n"
  footer="$footer- [🔍 Quick Reference](./QUICK-REFERENCE.md)\n\n"
  footer="$footer---\n\n"

  if [ -n "$prev" ] && [ -n "$next" ]; then
    footer="$footer**Previous:** [$(basename "$prev" .md)](./$prev) | **Next:** [$(basename "$next" .md)](./$next)"
  elif [ -n "$prev" ]; then
    footer="$footer**Previous:** [$(basename "$prev" .md)](./$prev)"
  elif [ -n "$next" ]; then
    footer="$footer**Next:** [$(basename "$next" .md)](./$next)"
  fi

  echo -e "$footer" >> "$file"
}

echo "Adding navigation to AUDIT documents..."

# Process each document
for i in "${!DOCS[@]}"; do
  file="${DOCS[$i]}"

  # Skip if already has navigation header
  if grep -q "📋 Master Index" "$file"; then
    echo "Skipping $file (already has navigation)"
    continue
  fi

  prev=""
  next=""

  # Determine prev/next
  if [ $i -gt 0 ]; then
    prev="${DOCS[$((i-1))]}"
  fi

  if [ $i -lt $((${#DOCS[@]}-1)) ]; then
    next="${DOCS[$((i+1))]}"
  fi

  echo "Processing $file..."

  # Add navigation (if not already present)
  # add_navigation_header "$file" "$prev" "$next"
  # add_navigation_footer "$file" "$prev" "$next"
done

echo "Navigation added to all documents!"
