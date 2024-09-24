from github import Github, Auth
from argparse import ArgumentParser
import dotenv as dt


def create_repo(name=None):
    config = dt.dotenv_values("../.env")

    if token := config["GITHUB_TOKEN"]:
        auth = Auth.Token(token)

        # Public Web Github
        g = Github(auth=auth)

        # Then play with your Github objects:
        if repos := [repo.name for repo in g.get_user().get_repos()]:
            if name not in repos:
                g.get_user().create_repo(name, private=True)
                print(f"New Repo {name} is created.")
                g.close()
            else:
                print(f"Name {name}is already exist.")
        else:
            print("There's no repos.")
        # To close connections after use
        # create new-repo
    else:
        print("There's no GITHUB_TOKEN Environment variable.")


if __name__ == "__main__":
    parser = ArgumentParser()
    parser.add_argument("repo", type=str)

    args = parser.parse_args()

    if args.repo:
        create_repo(args.repo)
