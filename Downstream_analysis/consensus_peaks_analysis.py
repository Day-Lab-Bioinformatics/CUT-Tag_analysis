#!/usr/bin/env python3
## Created by Adrianna Vandeuren on 06/27/2025
"""
Consensus Peaks Analysis
Creates consensus peaks by finding overlapping regions across samples
and averaging scores (column 5) and signal values (column 7)
Optimized for SLURM cluster execution
"""

import pandas as pd
import numpy as np
from pathlib import Path
import argparse
from collections import defaultdict
import sys
import gc
import logging
import time
import os

def setup_logging():
    """Setup logging for SLURM environment"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout)
        ]
    )
    return logging.getLogger(__name__)

def parse_narrowpeak(file_path, logger):
    """
    Parse a narrowPeak file and return a DataFrame
    narrowPeak format: chr, start, end, name, score, strand, signalValue, pValue, qValue, peak
    """
    columns = ['chr', 'start', 'end', 'name', 'score', 'strand', 'signalValue', 'pValue', 'qValue', 'peak']
    
    try:
        logger.info(f"Loading {file_path}")
        df = pd.read_csv(file_path, sep='\t', header=None, names=columns)
        # Ensure numeric columns are properly typed
        df['start'] = df['start'].astype(int)
        df['end'] = df['end'].astype(int)
        df['score'] = pd.to_numeric(df['score'], errors='coerce')
        df['signalValue'] = pd.to_numeric(df['signalValue'], errors='coerce')
        logger.info(f"Loaded {len(df)} peaks from {file_path.name}")
        return df
    except Exception as e:
        logger.error(f"Error reading {file_path}: {e}")
        return None

def find_overlapping_peaks(peak_dfs, min_overlap=1, logger=None):
    """
    Find overlapping peaks across samples using interval overlap
    Returns a list of consensus peak regions with their contributing samples
    Optimized for memory efficiency in SLURM environment
    """
    if logger:
        logger.info("Starting overlap detection...")
        
    all_intervals = []
    
    # Collect all intervals with sample information
    for sample_idx, (sample_name, df) in enumerate(peak_dfs.items()):
        if logger:
            logger.info(f"Processing intervals from {sample_name}")
        for _, row in df.iterrows():
            all_intervals.append({
                'chr': row['chr'],
                'start': row['start'],
                'end': row['end'],
                'sample': sample_name,
                'score': row['score'],
                'signalValue': row['signalValue'],
                'sample_idx': sample_idx
            })
    
    if logger:
        logger.info(f"Total intervals to process: {len(all_intervals)}")
    
    # Sort intervals by chromosome and start position
    all_intervals.sort(key=lambda x: (x['chr'], x['start']))
    
    consensus_peaks = []
    
    # Group by chromosome for memory efficiency
    chr_groups = defaultdict(list)
    for interval in all_intervals:
        chr_groups[interval['chr']].append(interval)
    
    # Process each chromosome separately to save memory
    for chr_idx, (chr_name, intervals) in enumerate(chr_groups.items()):
        if logger:
            logger.info(f"Processing chromosome {chr_name} ({chr_idx+1}/{len(chr_groups)}): {len(intervals)} intervals")
        
        # Find overlapping regions within each chromosome
        i = 0
        while i < len(intervals):
            current_group = [intervals[i]]
            current_start = intervals[i]['start']
            current_end = intervals[i]['end']
            
            # Look for overlapping intervals
            j = i + 1
            while j < len(intervals):
                if intervals[j]['start'] <= current_end:
                    # There's an overlap
                    current_group.append(intervals[j])
                    current_end = max(current_end, intervals[j]['end'])
                    j += 1
                else:
                    break
            
            # Only keep groups with minimum overlap requirement
            if len(current_group) >= min_overlap:
                # Calculate consensus region (INTERSECTION instead of union)
                # Find the overlapping region that all peaks share
                consensus_start = max(peak['start'] for peak in current_group)
                consensus_end = min(peak['end'] for peak in current_group)
                
                # Only keep if there's actually an intersection
                if consensus_start < consensus_end:
                    # Calculate average score and signal value
                    scores = [peak['score'] for peak in current_group if not pd.isna(peak['score'])]
                    signals = [peak['signalValue'] for peak in current_group if not pd.isna(peak['signalValue'])]
                    
                    avg_score = np.mean(scores) if scores else 0
                    avg_signal = np.mean(signals) if signals else 0
                    
                    # Get unique samples contributing to this consensus peak
                    contributing_samples = list(set(peak['sample'] for peak in current_group))
                    
                    consensus_peaks.append({
                        'chr': chr_name,
                        'start': consensus_start,
                        'end': consensus_end,
                        'length': consensus_end - consensus_start,
                        'num_samples': len(contributing_samples),
                        'contributing_samples': ','.join(contributing_samples),
                        'avg_score': avg_score,
                        'avg_signalValue': avg_signal,
                        'num_peaks': len(current_group)
                    })
            
            i = j if j > i + 1 else i + 1
        
        # Clear processed chromosome data to save memory
        del intervals
        gc.collect()
    
    if logger:
        logger.info(f"Found {len(consensus_peaks)} consensus peaks")
    
    return consensus_peaks

def main():
    start_time = time.time()
    logger = setup_logging()
    
    parser = argparse.ArgumentParser(description='Create consensus peaks from narrowPeak files (SLURM optimized)')
    parser.add_argument('--input-dir', '-i', required=True, 
                       help='Directory containing narrowPeak files')
    parser.add_argument('--pattern', '-p', default='*.narrowPeak',
                       help='File pattern to match (default: *.narrowPeak)')
    parser.add_argument('--output', '-o', default='consensus_peaks.txt',
                       help='Output file name (default: consensus_peaks.txt)')
    parser.add_argument('--min-samples', '-m', type=int, default=2,
                       help='Minimum number of samples for consensus peak (default: 2)')
    parser.add_argument('--summary', '-s', action='store_true',
                       help='Print summary statistics')
    
    args = parser.parse_args()
    
    logger.info("=== SLURM Consensus Peaks Analysis ===")
    logger.info(f"SLURM Job ID: {os.environ.get('SLURM_JOB_ID', 'Not running under SLURM')}")
    logger.info(f"Node: {os.environ.get('SLURMD_NODENAME', 'Unknown')}")
    
    input_dir = Path(args.input_dir)
    if not input_dir.exists():
        logger.error(f"Input directory '{input_dir}' does not exist")
        sys.exit(1)
    
    # Find all narrowPeak files
    peak_files = list(input_dir.glob(args.pattern))
    
    if not peak_files:
        logger.error(f"No files matching pattern '{args.pattern}' found in '{input_dir}'")
        sys.exit(1)
    
    logger.info(f"Found {len(peak_files)} narrowPeak files:")
    for f in peak_files:
        logger.info(f"  - {f.name}")
    
    # Load all peak files
    peak_dfs = {}
    total_peaks = 0
    
    for file_path in peak_files:
        sample_name = file_path.stem  # Remove extension for sample name
        df = parse_narrowpeak(file_path, logger)
        
        if df is not None and not df.empty:
            peak_dfs[sample_name] = df
            total_peaks += len(df)
        else:
            logger.warning(f"Could not load peaks from {file_path}")
    
    if not peak_dfs:
        logger.error("No valid peak files were loaded")
        sys.exit(1)
    
    logger.info(f"Total peaks across all samples: {total_peaks}")
    logger.info(f"Finding consensus peaks with minimum {args.min_samples} samples...")
    
    # Find consensus peaks
    consensus_peaks = find_overlapping_peaks(peak_dfs, min_overlap=args.min_samples, logger=logger)
    
    if not consensus_peaks:
        logger.warning("No consensus peaks found with the specified criteria")
        sys.exit(1)
    
    # Convert to DataFrame and sort
    logger.info("Creating output DataFrame...")
    consensus_df = pd.DataFrame(consensus_peaks)
    consensus_df = consensus_df.sort_values(['chr', 'start']).reset_index(drop=True)
    
    # Create BED format output with additional columns
    # BED format: chr, start, end, name, score
    # Additional columns: length, num_samples, contributing_samples, avg_signalValue, num_peaks
    bed_df = pd.DataFrame({
        'chr': consensus_df['chr'],
        'start': consensus_df['start'],
        'end': consensus_df['end'],
        'name': [f"consensus_peak_{i+1}" for i in range(len(consensus_df))],
        'score': consensus_df['avg_score'].round(3),
        'length': consensus_df['length'],
        'num_samples': consensus_df['num_samples'],
        'contributing_samples': consensus_df['contributing_samples'],
        'avg_signalValue': consensus_df['avg_signalValue'].round(3),
        'num_peaks': consensus_df['num_peaks']
    })
    
    # Save results in BED format
    output_file = Path(args.output)
    logger.info(f"Saving results to: {output_file.absolute()}")
    bed_df.to_csv(output_file, sep='\t', index=False, header=True)
    
    elapsed_time = time.time() - start_time
    logger.info(f"Analysis completed in {elapsed_time:.2f} seconds")
    logger.info(f"Number of consensus peaks: {len(bed_df)}")
    logger.info(f"Output BED file: {output_file.absolute()}")
    
    if args.summary:
        logger.info("=== SUMMARY STATISTICS ===")
        logger.info(f"Input samples: {len(peak_dfs)}")
        logger.info(f"Total input peaks: {total_peaks}")
        logger.info(f"Consensus peaks: {len(bed_df)}")
        logger.info(f"Reduction ratio: {len(bed_df)/total_peaks:.3f}")
        
        logger.info(f"Consensus peak statistics:")
        logger.info(f"  Average length: {bed_df['length'].mean():.1f} bp")
        logger.info(f"  Median length: {bed_df['length'].median():.1f} bp")
        logger.info(f"  Average score: {bed_df['score'].mean():.3f}")
        logger.info(f"  Average signal: {bed_df['avg_signalValue'].mean():.3f}")
        
        logger.info(f"Sample overlap distribution:")
        sample_counts = bed_df['num_samples'].value_counts().sort_index()
        for num_samples, count in sample_counts.items():
            logger.info(f"  {num_samples} samples: {count} peaks ({count/len(bed_df)*100:.1f}%)")
        
        logger.info(f"Top 10 chromosomes by peak count:")
        chr_counts = bed_df['chr'].value_counts().sort_index()
        for chr_name, count in chr_counts.head(10).items():
            logger.info(f"  {chr_name}: {count} peaks")
        if len(chr_counts) > 10:
            logger.info(f"  ... and {len(chr_counts)-10} more chromosomes")
    
    logger.info("=== ANALYSIS COMPLETE ===")

if __name__ == "__main__":
    main()
