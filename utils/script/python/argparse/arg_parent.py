import argparse

"""
 @anthor LingChen
 @create 12/17/2018 11:15 AM
 @Description
"""
parser = argparse.ArgumentParser(description='parent 1', add_help=False)
parser.add_argument('-p', '--password', help='What is your passwrd')
parser.add_argument('-user', '--username', help='What is your username')
parser.add_argument('-m', '--female', help='What is your female')
