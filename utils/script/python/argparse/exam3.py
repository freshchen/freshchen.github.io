import argparse

"""
 @anthor LingChen
 @create 12/17/2018 10:20 AM
 @Description
"""
parser = argparse.ArgumentParser(description='test 2')
parser.add_argument('-n', '--name', help="What's ur name")
args = parser.parse_args()
print(args)
print(args.name)
