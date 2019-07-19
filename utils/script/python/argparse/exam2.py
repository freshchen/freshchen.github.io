import argparse

"""
 @anthor LingChen
 @create 12/13/2018 2:53 PM
 @Description
"""

parser = argparse.ArgumentParser(description='test 2')
parser.add_argument('-a', dest="c")
parser.add_argument('b')
args = parser.parse_args()
print(args)
print(args.a)
print(args.b)
