# push-generated-file

A github action. Generate a file in your action then use this action to push it to a folder in another repository. You have to have permssion to push to that repository.

## Original work
- Forked from https://github.com/cpina/github-action-push-to-another-repository which, at the time, deleted the files in a target repository, then pushed a generated file into that blank repository.
- Edits were made based on https://github.com/dmnemec/copy_file_to_another_repo_action which, at the time, pushed a copy of an already existing file to a directory in a target repository.

## Inputs
### `source_file_path`
Path to your generated file or to multiple files. **Example: `'path/to/file.md'`**. I think it doesn't have to be in a folder. Maybe a file that already exists in your current repo would work too, but I haven't tried that yet.

### `destination_repo`
Repository to push file to. **Example: `'some_user/some_repo'`**

### `destination_folder`
Folder to create or use in destination repository. It can be a set of nested folders. **Example: `'.github/workflows'`**

### `target_branch`
[Optional] A branch in the destination repository. **Default is "main"**. I think the branch needs to already exist, but I'm not sure.

### `author`
[Optional] Name of the commit's author. **Default is user name of account doing the pushing**.

### `author_email`
[Optional] Email for the commit. **Default is `author@no-reply...`**

### `token`
Token/Secret that lets your repo push to a repo on which you have permissions. **Example: ${{ secrets.PUSH_FILE_TOKEN }}`**

Generate your personal token ([github instructions](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)):
1. Go to https://github.com/settings/tokens
1. Generate a new token
1. Choose to allow access to "repo"
1. Copy the token

Make the token available to the Github Action:
1. Go to the repository you will push from
1. Tap the 'Settings' tab
1. Tap 'Secrets' in the column on the left
1. Tap "Add a new secret"
1. Give it a name that will help you remember what it's for, like "PUSH_FILE_TOKEN"

## Example usage
```yaml
    steps:
      - uses: actions/checkout@v2
      - name: Create output folder and files
        run:  sh ./generate_files.sh
      - name: Push files
        uses: plocket/push-generated-file@master
        with:
          token: ${{ secrets.PUSH_FILE_TOKEN }}
          source_file_path: 'output'
          destination_repo: 'plocket/some-destination-repository'
          destination_folder: 'folder/in/repository'
          target_branch: 'feature-branch'
          author: 'plocket'
          author_email: 'plocket@example.com'
```

Working example dealing with multiple files and nested folders: https://github.com/plocket/source_repo/blob/main/.github/workflows/push_multiple_files.yml

Repo it pushes to: https://github.com/plocket/destination_repo
