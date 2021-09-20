from logging import error
import boto3
import argparse
import sys

def get_load_balancer_dns_name(client, args):
    
    try:
        response = client.describe_load_balancers(
        LoadBalancerNames=[
            args.loadbalancer_name,
        ],
        )
    except Exception as err:
        print(err)
        sys.exit()
    return response['LoadBalancerDescriptions'][0]['DNSName']


def main():
    client = boto3.client('route53')
    elb_client = boto3.client('elb')
    parser = argparse.ArgumentParser(description="cli tool for challenege")
    parser.add_argument("--env", help="environment loadbalancer is in")
    parser.add_argument("--loadbalancer-name", help="loadbalancer name")
    args = parser.parse_args()
    host_id = "Z031591819EUTH2ZTC48D"
    print("starting")

    load_balancer_dns_name = get_load_balancer_dns_name(elb_client, args)
    print(load_balancer_dns_name)
    paginator = client.get_paginator('list_resource_record_sets')
    source_zone_records = paginator.paginate(HostedZoneId=host_id)
    for record_set in source_zone_records:
        for record in record_set['ResourceRecordSets']:
            print(record['Name'])
            if record['Name'] == f"{args.env}.clouddatadynamics.com.":
                try:
                    change_res = client.change_resource_record_sets(
                        HostedZoneId=host_id,
                        ChangeBatch={
                            'Changes' : [ 
                            {
                                'Action' : 'DELETE',
                                'ResourceRecordSet' :{
                                    'Name' : record['Name'],
                                    'Type' : 'CNAME',
                                    'TTL' : 300,
                                    'ResourceRecords' : [
                                        {
                                            'Value' : record['ResourceRecords'][0]['Value']
                                        },
                                    ]
                                }
                            },
                            {
                                'Action' : 'UPSERT',
                                'ResourceRecordSet' : {
                                    'Name' : record['Name'],
                                    'Type' : 'CNAME',
                                    'TTL' : 300,
                                    'ResourceRecords' : [
                                        {
                                            'Value' : load_balancer_dns_name
                                        }
                                    ]

                                }

                            }
                            ]
                        }
                    )
                    print(change_res)
                except Exception as err:
                    print(err)
                    sys.exit()



if __name__ == '__main__':
    main()