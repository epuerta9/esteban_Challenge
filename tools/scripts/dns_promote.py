import boto3
import argparse

def main():
    parser = argparse.ArgumentParser(description="cli tool for challenege")
    parser.add_argument("--env", help="environment loadbalancer is in")
    parser.add_argument("--loadbalancer-name", help="loadbalancer name")



    args = parser.parse_args()

    if args.env == 'dev':
        pass
    elif args.env == 'stage':
        pass
    elif args.env == 'prod':
        pass
    else:
        print("no correct env specified")


if __name__ == '__main__':
    main()