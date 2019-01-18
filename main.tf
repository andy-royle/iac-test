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