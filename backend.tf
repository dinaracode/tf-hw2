terraform {
  backend "s3" {
    bucket = "dina-terraform"
    region = "us-east-1" #where bucket lives physically 
    key    = "hw2_tf_statefile"
  }
}