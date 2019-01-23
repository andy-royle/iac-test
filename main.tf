variable "prefix" {
  default = "rp-"
}
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "${var.prefix}jenkins"
    location = "eastus"

    tags {
        environment = "jenkins"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "${var.prefix}jenkinsVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    tags {
        environment = "jenkins"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "${var.prefix}jenkinsSubnet"
    resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
    virtual_network_name = "${azurerm_virtual_network.myterraformnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "${var.prefix}jenkinsPublicIP"
    location                     = "eastus"
    resource_group_name          = "${azurerm_resource_group.myterraformgroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "jenkins"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.prefix}jenkinsNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = "${azurerm_resource_group.myterraformgroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "89.197.133.42/32"
        destination_address_prefix = "*"
    }

	    security_rule {
        name                       = "WeWork"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080-8085"
        source_address_prefix      = "89.197.133.42/32"
        destination_address_prefix = "*"
    }
	   security_rule {
        name                       = "HalfordsProxy"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "85.115.33.180/32"
        destination_address_prefix = "*"
    }
	
	security_rule {
        name                       = "SecureRemote"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080-8085"
        source_address_prefix      = "85.115.54.202/32"
        destination_address_prefix = "*"
    }
	
	security_rule {
        name                       = "SecureRemoteSSH"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "85.115.54.202/32"
        destination_address_prefix = "*"
    }
	security_rule {
        name                       = "Spoke"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080-8085"
        source_address_prefix      = "213.86.26.11/32"
        destination_address_prefix = "*"
    }
	security_rule {
        name                       = "Spokessh"
        priority                   = 1007
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "213.86.26.11/32"
        destination_address_prefix = "*"
    }
	 security_rule {
        name                       = "Redditchssh"
        priority                   = 1008
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "213.123.45.201/32"
        destination_address_prefix = "*"
    }

	    security_rule {
        name                       = "Redditchotherports"
        priority                   = 1009
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080-8085"
        source_address_prefix      = "213.123.45.201/32"
        destination_address_prefix = "*"
	}	
	 security_rule {
        name                       = "Bitbuckethook"
        priority                   = 1010
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefixes    = ["104.192.136.0/21", "13.55.145.74/32", "13.236.225.70/32", "13.236.240.90/32", "13.236.240.218/32", "13.237.22.210/32", "13.237.203.34/32", "34.198.210.246/32", "34.252.194.82/32", "35.160.117.30/32", "35.162.23.98/32", "35.167.86.65/32", "104.192.136.0/21", "52.8.252.137/32", "34.198.211.97/32", "34.208.237.45/32", "35.161.3.151/32", "35.164.29.75/32", "35.166.83.147/32", "52.214.35.33/32", "54.72.233.229/32", "34.192.15.175/32", "52.9.41.1/32", "54.76.3.75/32", "103.233.242.0/24", "52.8.84.222/32", "13.55.123.56/32", "13.237.238.24/32", "34.198.178.64/32", "34.208.39.80/32", "35.162.54.42/32", "52.63.74.64/32", "185.166.140.0/22", "52.63.91.5/32", "52.215.192.128/25", "52.51.80.244/32", "34.198.32.85/32", "34.198.203.127/32", "13.55.180.21/32", "13.54.202.141/32", "13.52.5.0/25", "13.236.8.128/25", "18.136.214.0/25", "18.184.99.128/25", "18.234.32.128/25", "18.246.31.128/25", "34.208.209.12/32", "52.52.234.127/32", "18.205.93.0/27", "54.77.145.185/32"]
        destination_address_prefix = "*"
	}	
    tags {
        environment = "jenkins"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "${var.prefix}jenkinsNIC"
    location                  = "eastus"
    resource_group_name       = "${azurerm_resource_group.myterraformgroup.name}"
    network_security_group_id = "${azurerm_network_security_group.myterraformnsg.id}"

    ip_configuration {
        name                          = "${var.prefix}jenkinsNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags {
        environment = "jenkins"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.myterraformgroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "rpdiag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.myterraformgroup.name}"
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "jenkins"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "${var.prefix}jenkinsVM"
    location              = "eastus"
    resource_group_name   = "${azurerm_resource_group.myterraformgroup.name}"
    network_interface_ids = ["${azurerm_network_interface.myterraformnic.id}"]
    vm_size               = "Standard_B2ms"

    storage_os_disk {
        name              = "${var.prefix}jenkinsOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDl3/2TyNhFHKqTNEHE98oI8K5WsPaXKIJ5/mC3Bs3z3pdvH0MdeSsmty1STD9Tj34ZpT+xb1fwia2dfZhkiDy1BXPboOSGJ8pHVfuH8pID5vsyk38kXhRjjFKrV2vqYBZO1aPzFw9pUllpkQ0SZesXM+9SKYkoEGyUBzdKdZ3Twl2OzoXj/OHne7cqOOGkD4JU/UpZWYL3jA1k1hDpiux49ra/i6KudwoZi2FTepYPeDSZEDE+0n7DqFz6+WgkaBrO3/NgX3DgRNXIosQpXdtE8CgzbzL0rrkJzGNE2tKodeK85vJHowQkYGMSoxitaJjhK9ld5lhYC5pc5tuuptHP HAL00259@H26262"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "jenkins"
    }
}
resource "azurerm_managed_disk" "JenkinsData" {
  name                 = "${var.prefix}JenkinsDataDisk"
  location             = "eastus"
  resource_group_name  = "${azurerm_resource_group.myterraformgroup.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"

  tags {
    environment = "jenkins"
  }
}
resource "azurerm_virtual_machine_data_disk_attachment" "JenkinsData" {
  managed_disk_id    = "${azurerm_managed_disk.JenkinsData.id}"
  virtual_machine_id = "${azurerm_virtual_machine.myterraformvm.id}"
  lun                = "10"
  caching            = "ReadWrite"
}