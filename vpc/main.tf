#creating vpc from terraform

resource "aws_vpc" "petclinic" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enable

  tags = {
    Name = var.envname
  }
}


#subnets

resource "aws_subnet" "pubsubnet" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.pubsubnet,count.index)
  availability_zone =element(var.azs,count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.envname}-pubsubnet-${count.index+1}"
  }
}


resource "aws_subnet" "privsubnet" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.privsubnet,count.index)
  availability_zone =element(var.azs,count.index)
  

  tags = {
    Name = "${var.envname}-privsubnet-${count.index+1}"
  }
}

resource "aws_subnet" "datasubnet" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.datasubnet,count.index)
  availability_zone =element(var.azs,count.index)
  

  tags = {
    Name = "${var.envname}-datasubnet-${count.index+1}"
  }
}



#igw and vpc

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.petclinic.id

  tags = {
    Name = "${var.envname}-igw"
  }
}


#eip
resource "aws_eip" "natip" {
  vpc      = true

  tags = {
    Name = "${var.envname}-natip"
  }
}

#nat gateway

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.pubsubnet[0].id

  tags = {
    Name = "${var.envname}-natgw"
  }
  }

  #route table

  resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   tags = {
    Name = "${var.envname}-publicroute"
  }
}



  resource "aws_route_table" "privroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

   tags = {
    Name = "${var.envname}-privroute"
  }
}

