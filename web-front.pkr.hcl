# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  required_plugins {
    amazon = {
      version = ">= 1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/source
source "amazon-ebs" "debian" {
  ami_name      = "web-nginx-aws"
  instance_type = "t3.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "debian-*-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  ssh_username = "admin"
}

# https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "web-nginx"
  sources = [
    "source.amazon-ebs.debian"
  ]
  
  # https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/provisioner
  provisioner "shell" {
    inline = [
      "echo creating directories",
      "sudo mkdir -p /web/html",
      "sudo mkdir -p /tmp/web",
      "sudo chown -R admin:admin /web",
      "sudo chown -R admin:admin /tmp/web"
    ]
  }

  provisioner "file" {
    source      = "files/index.html"
    destination = "/web/html/index.html"
  }

  provisioner "file" {
    source      = "files/nginx.conf"
    destination = "/tmp/web/nginx.conf"

  }

  provisioner "shell" {
  script = "scripts/install-nginx"
  }

  provisioner "shell" {
    script = "scripts/setup-nginx"
  }

  provisioner "shell" {
    inline = [
      "sudo nginx -t",
      "sudo systemctl enable nginx",
      "sudo systemctl restart nginx"
    ]
  }

}

