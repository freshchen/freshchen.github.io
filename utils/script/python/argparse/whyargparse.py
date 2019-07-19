import argparse

"""
 @anthor LingChen
 @create 12/14/2018 10:49 AM
 @Description
"""


def calculator(args):
    operation = args.operation
    x = args.x
    y = args.y
    if "add" == operation:
        return x + y
    elif "mod" == operation:
        return x % y
    elif "sub" == operation:
        return x - y
    elif "div" == operation:
        return x / y
    elif "mul" == operation:
        return x * y


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--x", type=float, default=1.0, help="What is the first number")
    parser.add_argument("--y", type=float, default=1.0, help="What is the second number")
    parser.add_argument("--operation", type=str, help="What operation? [add,mod,sub,div,mul]")
    args = parser.parse_args()
    print(args)
    print(calculator(args))


if __name__ == '__main__':
    main()
