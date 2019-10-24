#!/usr/bin/env bash

function setup() {
    cd $HOME
    mkdir .developer_add_tmp
    cd .developer_add_tmp/
}

function install_dependencies() {
  # This is a program to automate building pull-requests it is pretty cool
  # check it out here https://github.com/github/hub
  brew install hub
}

function clone_ibotta_monolith() {
    git clone git@github.com:Ibotta/Ibotta.git
}

function checkout_branch() {
  cd Ibotta/
  git checkout develop
  git pull origin develop
  read -p "Story associated with addition: (blank if you don't have one) " -r story

  if [ -z "$story" ]
  then
    read -p "Enter name: (This will be your branch name so no whitespace please :)) " -r name
    git checkout -b $name
  else
    git checkout -b $story
  fi
  cd ./script/developer_account/
}

function get_user_info() {
  read -p "Enter Customer ID:" -r customer_id

  read -p "Enter Customer Name/Description:" -r customer_name

  echo "${customer_id},${customer_name}" >> developer_accounts.csv
}

function commit_changes() {
  echo "Committing your changes..."
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}
  echo $branch_name
  git add .
  git commit -m "Added name to customers list"
  git push origin $branch_name
}

function create_pull_request() {
  hub pull-request -b develop
  echo "Copy the above URL and get it approved and merged"
}

function cleanup() {
    echo "Cleaning up from script..."
    cd $HOME
    rm -rf .developer_add_tmp/
    echo "Do you want to uninstall Hub with brew?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) brew uninstall hub; break;;
            No ) break;;
        esac
    done
}

function run_through_customer_addition() {
  setup
  clone_ibotta_monolith
  checkout_branch
  get_user_info
  commit_changes
  create_pull_request
  cleanup
}

echo "Do you have access to your customer ID from admin?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) run_through_customer_addition; break;;
        No ) exit;;
    esac
done

