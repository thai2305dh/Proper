output "vpc" {
  value = {
    vpc_id        = aws_vpc.vpc.id
    public_subnet = [for subnet in aws_subnet.public_subnet : subnet.id]
  }
}