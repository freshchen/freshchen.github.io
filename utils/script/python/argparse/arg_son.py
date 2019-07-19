import argparse
import arg_parent

"""
 @anthor LingChen
 @create 12/17/2018 1:11 PM
 @Description
"""
parser = argparse.ArgumentParser(description='son 1', parents=[arg_parent.parser], conflict_handler='resolve')
parser.add_argument('-w', '--weather', help="What's the weather")
parser.add_argument('-m', '--female', action='store_const', const='TRUE', help='What is your female')
args = parser.parse_args()
print(args)
