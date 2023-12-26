import yaml

def add_map_users_to_aws_auth(file_path, user_arn, username):
    with open(file_path, 'r') as file:
        aws_auth = yaml.safe_load(file)
    
    map_users = [
        {
            "userarn": user_arn,
            "username": username,
            "groups": ["system:masters"]
        }
    ]

    if 'mapUsers' not in aws_auth['data']:
        aws_auth['data']['mapUsers'] = yaml.dump(map_users, default_flow_style=False).strip()

    with open(file_path, 'w') as file:
        yaml.dump(aws_auth, file)

if __name__ == '__main__':
    add_map_users_to_aws_auth('aws-auth.yaml', 'arn:aws:iam::11122223333:user/YourNewUser', 'YourNewUser')
