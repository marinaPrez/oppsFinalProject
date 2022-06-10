output "vpcid" {
    value = aws_vpc.oppschool_vpc.id
}


output "public-subnet-id"{
    value = aws_subnet.public.*.id
}


output "private-subnet-id"{
    value = aws_subnet.private.*.id
}
