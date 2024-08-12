terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }


}

provider "aws" {
  region     = var.aws_region
  access_key = "ASIA6PAJKYEWMILZDD2Q"
  secret_key = "OEwbQ7GjxRMjt0OGScm4trJ2/VGJxtD2HmBd+677"
  token      = "IQoJb3JpZ2luX2VjEJr//////////wEaCXVzLXdlc3QtMiJHMEUCIQCswg1ommq0l9ye3gW4VZLBUd6COuc0RV/dWY8U7y4pJQIgJaIeQuuQr9d+hltLqKICtkA/4uCfdbbgtqyrDdu/YmUqxwIIk///////////ARAAGgw5OTQzMDQ1MDgyMDQiDB7vkP+OtVCYxZX2SiqbAu0BLiYhNpA7FN6iNTalgFi8DIUcqkTiXWeeT5bhfFdiJO+b1TRoT55SZnjNrqIFIWVWo2Ko9p5LVUaxi2O77v6m7KxX+PxQrlOUQiGafLBh9Q/RmCvCFM+/KgKtAK4fwD/bSZ9zfh2KxgDcxMAAlhFkCC8ecCoVQm8GA3KFJgkYCQNNb6eb3YrdkgKnRGKtvXU9eHOGYlnhkflDyuySTXgwzKfIBfhcHC2GQ9ivy3go+iUJnnBCxx8pA24jpw8X2Jqd2W5vNtZm8D2QWBc4Gm3DTzQBJjB4sDL5E5C/+mvkvKp8zY81aaAKt0iowifwiGYkDuD3z6YAXyYFskHX88aa+sq1lY34V9blGTed67X00MVaKxvu7Epxz0Aw0JHptQY6nQHWNaj1uR5tZRcVFg4r3s/u7u0S74otfdbiRTaFt1WIZClFCOplkCieFkCmJgAYi6SAqqry5NnDWFLr6AtQAMHSB1vBQjLo8uRK8tYkWDIToU6H3NCF+r5I2pQb8ROgtl2nH0JI2sCTyNbdcaL20oqorsKbNZQARymQbjH7xg7syJqaRbpLcz4asX/vzNP/TPEVcQ41+Fw7eSTW5sU7"

    default_tags {
    tags = local.common_tags
  }
}

# provider "assume_role" {

#   region = var.aws_region

#   assume_role {
#     role_arn = var.assume_role_arn
#   }

#   default_tags {
#     tags = local.common_tags
#   }

# }

