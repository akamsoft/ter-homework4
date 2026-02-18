#создаем облачную сеть
#resource "yandex_vpc_network" "develop" {
#  name = "develop"
#}

#создаем подсеть
#resource "yandex_vpc_subnet" "develop_a" {
#  name           = "develop-ru-central1-a"
#  zone           = "ru-central1-a"
#  network_id     = yandex_vpc_network.develop.id
#  v4_cidr_blocks = ["10.0.1.0/24"]
#}

#resource "yandex_vpc_subnet" "develop_b" {
#  name           = "develop-ru-central1-b"
#  zone           = "ru-central1-b"
#  network_id     = yandex_vpc_network.develop.id
#  v4_cidr_blocks = ["10.0.2.0/24"]
#}

module "vpc_dev" {
  source = "./modules/vpc"
  name     = "dev"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" }
  ]
}

module "test-vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "dev" 
  network_id     = module.vpc_dev.vpc_id
  subnet_zones   = [module.vpc_dev.subnet_zones[0]]
  subnet_ids     = [module.vpc_dev.subnet_ids[0]]
  instance_name  = "web1"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "marketing"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

  depends_on = [module.vpc_dev]

}

module "example-vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "dev"
  network_id     = module.vpc_dev.vpc_id
  subnet_zones   = [module.vpc_dev.subnet_zones[0]]
  subnet_ids     = [module.vpc_dev.subnet_ids[0]]
  instance_name  = "web2"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "analytics"
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered #Для демонстрации №3
    serial-port-enable = 1
  }

  depends_on = [module.vpc_dev]

}

#Пример передачи cloud-config в ВМ для демонстрации №3
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_public_key = var.public_key
  }

}

