#!/bin/bash
# Syncs knowledge files to a local export folder for NotebookLM ingestion.

EXPORT_DIR="./notebooklm-export"
mkdir -p "$EXPORT_DIR"

echo "Syncing knowledge files to $EXPORT_DIR..."

cp knowledge/heuristics.md "$EXPORT_DIR/"
cp knowledge/design-system-rules.md "$EXPORT_DIR/"
cp knowledge/competitor-list.md "$EXPORT_DIR/"
cp knowledge/product-principles/principles.md "$EXPORT_DIR/product-principles.md"

# Include competitor deep-dives if present
if [ "$(ls -A knowledge/competitors 2>/dev/null)" ]; then
  cp knowledge/competitors/*.md "$EXPORT_DIR/"
fi

echo "Done. Files in $EXPORT_DIR:"
ls "$EXPORT_DIR"
