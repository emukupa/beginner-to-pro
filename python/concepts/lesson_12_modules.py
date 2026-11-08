"""Modules from the standard library: sys, os, datetime. And argparse, which the tracker skips."""
import argparse
import os
import sys
from datetime import date

TITLE = "Standard library"


def run():
    print("sys.argv (the words typed after python3):", sys.argv)
    print("TASKS_FILE from the environment:", os.getenv("TASKS_FILE", "tasks.txt (the default)"))
    print("today:", date.today().isoformat())
    parser = argparse.ArgumentParser(prog="tracker")
    parser.add_argument("path", nargs="?", default="tasks.txt")
    print("argparse would give:", parser.parse_args(["work.txt"]))
    # argparse also writes --help and error messages for you. The tracker takes one optional
    # file name, so sys.argv is enough; a program with options should use argparse.
    print("this lesson is a module too:", __name__)
