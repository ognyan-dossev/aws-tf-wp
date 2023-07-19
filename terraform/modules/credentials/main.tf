resource "tls_private_key" "wp_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "wp_aws_key" {
  key_name   = var.key_name
  public_key = tls_private_key.wp_key.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.wp_key.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", "ssh-key.pem")
  file_permission = "0600"
}

