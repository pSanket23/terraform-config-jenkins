data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "template_file" "cicd_user_data" {
    template = file("./cicd_user_data.tpl")
}

data "template_file" "app_user_data" {
    template = file("./app_user_data.tpl")
}