#!/usr/bin/env python3
import sys
def func1():
    for line in sys.stdin:
        print(line)

def func2():
    line = input("")
    while line:
        print(line)
        line = input("")

    
func2()
