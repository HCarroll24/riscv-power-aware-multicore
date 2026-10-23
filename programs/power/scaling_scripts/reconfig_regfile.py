"""
Filename: reconfig_regfile.py
Author: Hunter Carroll <carrollh@msoe.edu>
Version: 1.0
Brief: This script is used to reconfigure the register file of a given design.
It scales down the register file to only use registers needed and rewrites the vhdl.
"""
import argparse
import difflib
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Prefix at column 0 of every line script comments out
# restoring strips this prefix, easier restore
PRUNE_PREFIX = "--@RECONFIG "

# tag added on end of ever line script inserts
GET_TAG = "--@RECONFIG_GEN"

