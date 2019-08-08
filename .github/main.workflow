workflow "Terraform" {
  on = "pull_request"
  resolves = ["terraform-validate"]
}

action "terraform-validate" {
  uses = "innovationnorway/terraform-action/validate@master"
  secrets = ["GITHUB_TOKEN"]
}

workflow "Semantic Release" {
  on = "push"
  resolves = ["semantic-release"]
}

action "filter-master-branch" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "semantic-release" {
  uses = "innovationnorway/github-action-semantic-release@master"
  needs = "filter-master-branch"
  secrets = ["GH_TOKEN"]
}
